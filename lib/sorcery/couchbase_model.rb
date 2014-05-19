module Sorcery

  module CouchbaseModel
    def self.included(klass)
      klass.class_eval do
        class << self
          alias :orig_authenticates_with_sorcery! :authenticates_with_sorcery!

          def authenticates_with_sorcery!
            orig_authenticates_with_sorcery!
            init_couchbase_support! if defined?(Couchbase) && self.ancestors.include?(Couchbase::Model)
          end

          protected

          def init_couchbase_support!
            self.class_eval do
              sorcery_config.username_attribute_names.each do |username|
                attribute username
              end
              attribute sorcery_config.email_attribute_name unless sorcery_config.username_attribute_names.include?(sorcery_config.email_attribute_name)
              attribute sorcery_config.crypted_password_attribute_name
              attribute sorcery_config.salt_attribute_name

              if sorcery_config.respond_to? :activation_token_attribute_name
                attribute sorcery_config.activation_token_attribute_name
                attribute sorcery_config.activation_state_attribute_name
                attribute sorcery_config.activation_token_expires_at_attribute_name
              end

              if sorcery_config.respond_to? :remember_me_token_expires_at_attribute_name
                attribute sorcery_config.remember_me_token_attribute_name
                attribute sorcery_config.remember_me_token_expires_at_attribute_name

                define_method sorcery_config.remember_me_token_expires_at_attribute_name do
                  time = read_attribute(sorcery_config.remember_me_token_expires_at_attribute_name)
                  case time
                  when Array
                    Time.utc *time
                  when String
                    Time.new time
                  else
                    time
                  end
                end
              end

              view :all
              view *_sorcery_view_attributes.map { |attr| "by_#{attr}" }
              ensure_sorcery_design_document!
            end
          end

          def ensure_sorcery_design_document!
            bucket.save_design_doc(_sorcery_design_doc)
          end

          def _sorcery_design_doc
            doc = {
              '_id'      => "_design/#{design_document}",
              'language' => 'javascript',
              'views' => {
                'all' => {
                  'map' => <<-JS
                    function (doc, meta) {
                      if (doc.type && doc.type == '#{design_document}')
                        emit(meta.id, null);
                    }
                  JS
                }
              }
            }

            _sorcery_view_attributes.each do |attribute|
              doc['views']["by_#{attribute}"] = {
                'map' => <<-JS
                  function (doc, meta) {
                    if (doc.type && doc.type == '#{design_document}')
                      emit(doc.#{attribute}, null);
                  }
                JS
              }
            end

            doc
          end

          def _sorcery_view_attributes
            attributes = sorcery_config.username_attribute_names
            attributes << sorcery_config.activation_token_attribute_name  if sorcery_config.respond_to? :activation_token_attribute_name
            attributes << sorcery_config.remember_me_token_attribute_name if sorcery_config.respond_to? :remember_me_token_attribute_name
            attributes << sorcery_config.reset_password_token_attribute_name if sorcery_config.respond_to? :reset_password_token_attribute_name
            attributes << sorcery_config.email_attribute_name
            attributes.uniq
          end
        end
      end
    end
  end
end
