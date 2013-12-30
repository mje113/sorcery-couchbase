require 'helper'

class TestCouchbaseAdapter < Minitest::Test

  def setup
    @email = 'bar@example.com'
    TestUser.bucket.connect unless TestUser.bucket.connected?
  end

  def test_initialization
    assert TestUser.new
  end

  def test_find_by_credentials
    user = TestUser.create!(email: @email)
    assert_equal @email, TestUser.find_by_credentials([ @email ]).email
  end

  def test_not_found_credentials
    assert_nil TestUser.find_by_credentials([ 'fu@example.com' ])
  end
end
