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
      redirect_to organization_path, notice: "Organisation wurde aktualisiert."
      ProcessPictureJob.set(wait: 5.seconds).perform_later(@organization.logo.blob.id) if @organization.logo.attached?
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
    params.require(:organization).permit(
      :logo, :name, :email, :contact_person, :instagram_url, :facebook_link, :linkedin_url, :tiktok_url, :linktree_url, :contact_number, :profile_picture, :description, :is_approved, :city, :zip, :street, :housenumber, :website
    )
  end
end

<% if @organization.profile_picture.attached? %>
  <%= image_tag @organization.profile_picture_url, alt: @organization.name, class: "rounded-full w-32 h-32 object-cover" %>
<% else %>
  <%= image_tag "default_org.png", alt: "No profile picture", class: "rounded-full w-32 h-32 object-cover" %>
<% end %>

<%= form_with(model: @organization, local: true, html: { multipart: true }) do |form| %>
  <%= form.file_field :profile_picture %>
  <!-- other fields -->
<% end %>