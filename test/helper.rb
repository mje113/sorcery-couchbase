gem 'minitest'
require 'minitest/autorun'
require 'sorcery_couchbase'
require 'pry'

MockMailer = {}

Sorcery::Controller::Config.submodules = [ :user_activation, :remember_me, :reset_password ]
Sorcery::Controller::Config.user_config do |user|
  user.reset_password_mailer = MockMailer
end

class TestUser < Couchbase::Model
  authenticates_with_sorcery!
end

# Couchbase.bucket.flush

class Minitest::Test

end
