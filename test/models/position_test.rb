require 'test_helper'

class PositionTest < ActiveSupport::TestCase
  fixtures :positions, :organizations # Load the fixtures you need

  test "position should be valid" do
    position = positions(:position_one) # Access the 'position_one' fixture
    assert position.valid?
    assert_equal "Volunteer Position 1", position.title
    assert_equal organizations(:one), position.organization # Access associated organization
  end
end