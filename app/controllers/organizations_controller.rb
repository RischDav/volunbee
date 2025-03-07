class OrganizationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_organization, only: [:show, :edit, :update, :release, :lock], unless: -> { current_user.admin? }

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
    @organization = Organization.find(params[:id])
  end

  def update
    if @organization.update(organization_params)
      redirect_to organization_path, notice: "Organization was successfully updated."
      AdminMailer.organization_change_email.deliver_later
    else
      render :edit
    end
  end

  def release
    organization = Organization.find(params[:id])
    organization.update(released: true)
    redirect_to organizations_path, notice: 'Organisation wurde freigegeben.'
  end

  def lock
    organization = Organization.find(params[:id])
    organization.update(released: false)
    redirect_to organizations_path, notice: 'Organisation wurde gesperrt.'
  end

  private

  def set_organization
    @organization = Organization.find_by(id: current_user.organization_id)
  end

  def organization_params
    params.require(:organization).permit(:name, :email, :contact_number, :profile_picture, :is_approved, :city, :zip, :street, :housenumber, :website)
  end
end