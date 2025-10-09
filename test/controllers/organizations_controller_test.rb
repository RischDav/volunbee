require "test_helper"

class OrganizationsControllerTest < ActionDispatch::IntegrationTest 
  setup do
    @admin = users(:admin)
    @regular_user = users(:regular)
    @organization = organizations(:organization_1)
    @other_organization = organizations(:organization_2)
  end
 
  test "admin should get index with all organizations" do
    sign_in @admin
    get organizations_path
    assert_response :success
    assert_not_nil assigns(:organizations)
    assert_equal Organization.count, assigns(:organizations).count
  end

  test "regular user should get their own organization only" do
    sign_in @regular_user
    get organizations_path
    assert_response :success
    assert_not_nil assigns(:organization)
    assert_equal @organization.id, assigns(:organization).id
  end
end
