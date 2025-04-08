require "test_helper"

class OrganizationsControllerTest < ActionDispatch::IntegrationTest 
  setup do
    @admin = users(:admin)
    @regular_user = users(:regular)
    @organization = organizations(:one)
    @other_organization = organizations(:two)
    @regular_user.update(organization_id: @organization.id)
  end
 
  test "admin should get index with all organizations" do
    sign_in @admin
    get organizations_path
    assert_response :success
    assert_not_nil assigns(:organizations)
    assert_equal Organization.count, assigns(:organizations).count
  end
end
