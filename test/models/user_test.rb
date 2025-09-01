require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "should be valid with valid attributes" do
    user = User.new(
      email: "test@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
    assert user.valid?
  end
  
  test "should require email" do
    user = User.new(password: "password123")
    assert_not user.valid?
    assert_includes user.errors[:email], "can't be blank"
  end
  
  test "should require password" do
    user = User.new(email: "test@example.com")
    assert_not user.valid?
    assert_includes user.errors[:password], "can't be blank"
  end
end
