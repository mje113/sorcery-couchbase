require 'active_model'
require 'couchbase'
require 'couchbase/model'
require 'sorcery_couchbase/version'
require 'sorcery'
require 'sorcery/model/adapters/couchbase'
require 'sorcery/couchbase_model'

Couchbase::Model.send(:include, Sorcery::Model)
Couchbase::Model.send(:include, Sorcery::CouchbaseModel)
Couchbase::Model.send(:include, Sorcery::Model::Adapters::Couchbase)
