gem 'minitest'
require 'minitest/autorun'
require 'sorcery_couchbase'
require 'pry'

class MockMailer
  def self.activation_needed_email(user)
  end

  def self.activation_success_email(user)
  end
end

Sorcery::Controller::Config.submodules = [ :user_activation, :remember_me, :reset_password ]
Sorcery::Controller::Config.user_config do |user|
  user.user_activation_mailer = MockMailer
  user.reset_password_mailer = MockMailer
end

class TestUser < Couchbase::Model
  authenticates_with_sorcery!

  attribute :role, default: 'user'
end

Couchbase.bucket.flush

Minitest.after_run { Couchbase.disconnect; TestUser.bucket.disconnect }

class Minitest::Test

  def password
    's3cr3t'
  end

  def user
    @@user ||= begin
      TestUser.bucket.connect unless TestUser.bucket.connected?
      user = TestUser.create(email: 'bar@example.com')
      user.password = password
      fail unless user.save
      user.activate!
      user
    end
  end
end
