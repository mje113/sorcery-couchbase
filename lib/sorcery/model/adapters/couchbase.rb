module Sorcery
  module Model
    module Adapters
      module Couchbase
        def self.included(klass)
          klass.extend ClassMethods
          klass.send(:include, InstanceMethods)
        end

        module InstanceMethods
          def increment(attr)
            self.write_attribute(attr, self.read_attribute(attr).to_i + 1 )
          end

          def update_many_attributes(attrs)
            self.update(attrs)
          end

          def update_single_attribute(name, value)
            update_many_attributes(name => value)
          end
        end

        module ClassMethods

          def sorcery_view(view)
            ::Couchbase::View.new(bucket, "_design/#{design_document}/_view/by_#{view}", { wrapper_class: self, include_docs: true })
          end

          def credential_regex(credential)
            @sorcery_config.downcase_username_before_authenticating ? credential.downcase : credential
          end

          def find_by_credentials(credentials)
            user = nil
            sorcery_config.username_attribute_names.each do |attribute|
              user = sorcery_view(attribute).fetch(key: credential_regex(credentials[0]), stale: false).first
              break if user
            end
            user
          end

          def find_by_provider_and_uid(provider, uid)
            @user_klass ||= ::Sorcery::Controller::Config.user_class.to_s.constantize
            where(@user_klass.sorcery_config.provider_attribute_name => provider, @user_klass.sorcery_config.provider_uid_attribute_name => uid).first
          end

          def find_by_activation_token(token)
            sorcery_view(sorcery_config.activation_token_attribute_name).fetch(key: token, stale: false).first
          end

          def find_by_remember_me_token(token)
            sorcery_view(sorcery_config.remember_me_token_attribute_name).fetch(key: token, stale: false).first
          end

          def find_by_username(username)
            find_by_credentials(username)
          end


          def find_by_sorcery_token(token_attr_name, token)
            where(token_attr_name => token).first
          end

          def find_by_email(email)
            where(sorcery_config.email_attribute_name => email).first
          end

          # def get_current_users
          #   config = sorcery_config
          #   where(config.last_activity_at_attribute_name.ne => nil) \
          #   .where("this.#{config.last_logout_at_attribute_name} == null || this.#{config.last_activity_at_attribute_name} > this.#{config.last_logout_at_attribute_name}") \
          #   .where(config.last_activity_at_attribute_name.gt => config.activity_timeout.seconds.ago.utc).order_by([:_id,:asc])
          # end
        end
      end
    end
  end
end
