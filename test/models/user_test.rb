require "test_helper"

class UserTest < ActiveSupport::TestCase
  # Use fixtures to load data
  fixtures :users, :organizations

  def setup
    @user = users(:regular_user)    # Use the user fixture data
    @admin = users(:admin)  # Use the admin fixture data
   # @organization = organizations(:org_one)  # Use the organization fixture data
  end

  # Test that user is valid with correct attributes
  test "should be valid with valid attributes" do
    assert @user.valid?
    assert @admin.valid?
  end

end
