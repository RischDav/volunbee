class OrganizationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_organization, only: [ :edit, :update ]

  def index
    @organization = Organization.find_by(id: current_user.organization_id)
  end

  def edit
  end

  def update
    if @organization.update(organization_params)
      redirect_to organization_index_path, notice: "Organization was successfully updated."
    else
      render :edit
    end
  end

  private

  def set_organization
    @organization = Organization.find_by(id: current_user.organization_id)
  end

  def organization_params
    params.require(:organization).permit(:name, :email, :contact_number, :profile_picture, :is_approved, :is_deactivated)
  end
end
