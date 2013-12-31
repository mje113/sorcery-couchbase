require 'helper'

class TestCouchbaseAdapter < Minitest::Test

  def setup
    user
  end

  def test_initialization
    assert TestUser.new
  end

  def test_find_by_credentials
    assert_equal user.email, TestUser.find_by_credentials([ user.email ]).email
  end

  def test_not_found_credentials
    assert_nil TestUser.find_by_credentials([ 'fu@example.com' ])
  end

  def test_can_authenticate
    TestUser.authenticate(user.email, password)
    assert_equal user.id, TestUser.authenticate(user.email, password).id
  end

  def test_can_update_atributes
    assert user.update_many_attributes(role: 'admin')
    assert_equal 'admin', user.role
  end
end
