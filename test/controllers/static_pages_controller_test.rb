require "test_helper"

class StaticPagesControllerTest < ActionDispatch::IntegrationTest
  test "should get imprint" do
    get static_pages_imprint_url
    assert_response :success
  end
end
