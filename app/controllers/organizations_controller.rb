class OrganizationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_organization, only: [ :show, :edit, :update ], unless: -> { current_user.admin? }

  def index
    if current_user.admin?
      @organizations = Organization.all
    else
      @organization = Organization.find_by(id: current_user.organization_id)
    end
  end

  def edit
  end

  def show
  end
  def show
    @organization = Organization.find(params[:id])
  end

  def update
    if @organization.update(organization_params)
      redirect_to organization_path, notice: "Organization was successfully updated."
    else
      render :edit
    end
  end

  private

  def set_organization
    @organization = Organization.find_by(id: current_user.organization_id)
  end

  def organization_params
  params.require(:organization).permit(:name, :email, :contact_number, :profile_picture, :is_approved, :city, :zip, :street, :housenumber, :website)
  end
end
