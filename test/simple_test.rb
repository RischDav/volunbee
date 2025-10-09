require "test_helper"

class SimpleTest < ActiveSupport::TestCase
  test "basic test infrastructure works" do
    assert true
  end
  
  test "can access database" do
    assert_equal 0, User.count
  end
end
