class OrganizationApplicationsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_organization!

  def index
    @organization = current_user.organization
    @positions = @organization.positions.includes(:messages).order(created_at: :desc)
    @events = @organization.events.includes(:messages).order(created_at: :desc)
  end

  def update
    @message = Message.left_joins(:position, :event)
                      .where("positions.organization_id = ? OR events.organization_id = ?", current_user.organization.id, current_user.organization.id)
                      .find(params[:id])
    if @message.update(accepted: params[:accepted])
      flash[:notice] = "Bewerbung wurde #{@message.accepted ? 'akzeptiert' : 'abgelehnt'}."
    else
      flash[:alert] = "Fehler beim Aktualisieren der Bewerbung."
    end
    redirect_to organization_applications_path
  end

  private

  def ensure_organization!
    unless current_user.organization?
      flash[:alert] = "Zugriff nur für Organisationen."
      redirect_to root_path
    end
  end
end