class EventsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_event, only: [:show, :edit, :update, :destroy, :release, :lock, :online, :offline, :delete_picture]
  before_action :check_edit_permissions, only: [:edit, :update, :destroy]
  before_action :check_admin_permissions, only: [:release, :lock]
  before_action :check_online_offline_permissions, only: [:online, :offline]
  
  # GET /events
  def index
    if user_signed_in? && current_user.admin?
      @events = Event.all.order(created_at: :desc)
    elsif user_signed_in? && current_user.organization?
      @events = Event.where(organization_id: current_user.organization&.id).order(created_at: :desc)
    else
      # Öffentliche Ansicht: nur veröffentlichte und online Events
      @events = Event.published.upcoming
    end
    @events_count = @events.size
  end
  
  # GET /events/new
  def new
    @event = Event.new
  end
  
  # POST /events
  def create
  @event = Event.new(event_params)
  @event.organization = current_user.organization if current_user.organization?
  @event.user = current_user

  if @event.save
    # Bilder asynchron verarbeiten
    [:main_picture, :picture1, :picture2, :picture3].each do |pic|
      if @event.send(pic).attached?
        ProcessPictureJob.set(wait: 5.seconds).perform_later(@event.send(pic).blob.id)
      end
    end
    redirect_to positions_path, notice: "Event wurde erfolgreich erstellt."  # <-- HIER geändert
  else
    flash.now[:alert] = @event.errors.full_messages.join(", ")
    render :new, status: :unprocessable_entity
  end
end
  
  # GET /events/:id
  def show
    # Logik für Studenten-Event-View (optional)
    if user_signed_in? && current_user.student?
      # EventViewLog.create(user: current_user, event: @event) – falls gewünscht
    end
  end
  
  # GET /events/:id/edit
  def edit
  end
  
  # PATCH/PUT /events/:id
  def update
    # Vorhandene Bilder löschen, wenn entsprechende Checkbox gesetzt
    if params[:delete_main_picture] == "1"
      @event.main_picture.purge
    end
    if params[:delete_picture1] == "1"
      @event.picture1.purge
    end
    if params[:delete_picture2] == "1"
      @event.picture2.purge
    end
    if params[:delete_picture3] == "1"
      @event.picture3.purge
    end
    if @event.update(event_params)
      redirect_to events_path, notice: "Event wurde aktualisiert."
    else
      flash.now[:alert] = @event.errors.full_messages.join(", ")
      render :edit, status: :unprocessable_entity
    end
  end
  
  # DELETE /events/:id
  def destroy
    @event.destroy
    redirect_to events_path, notice: "Event wurde gelöscht."
  end
  
  # PATCH /events/:id/release (Admin)
  def release
    @event.update(released: true)
    redirect_to events_path, notice: "Event wurde freigegeben."
  end
  
  # PATCH /events/:id/lock (Admin)
  def lock
    @event.update(released: false)
    redirect_to events_path, notice: "Event wurde gesperrt."
  end
  
  # PATCH /events/:id/online
  def online
    @event.update(online: true)
    redirect_to events_path, notice: "Event ist jetzt online sichtbar."
  end
  
  # PATCH /events/:id/offline
  def offline
    @event.update(online: false)
    redirect_to events_path, notice: "Event ist offline."
  end
  
  # DELETE /events/:id/delete_picture/:picture_type
  def delete_picture
    picture_type = params[:picture_type]
    if @event.send(picture_type).attached?
      @event.send(picture_type).purge
      redirect_to edit_event_path(@event), notice: "Bild wurde gelöscht."
    else
      redirect_to edit_event_path(@event), alert: "Kein Bild zum Löschen."
    end
  end
  
  private
  
  def set_event
    @event = Event.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to events_path, alert: "Event nicht gefunden."
  end
  
  def event_params
    params.require(:event).permit(
      :title, :description, :benefits, :location, :start_date, :end_date,
      :event_type, :contact_person, :contact_email, :contact_phone, :website,
      :released, :online,
      :main_picture, :picture1, :picture2, :picture3
    )
  end
  
  def check_edit_permissions
    unless can_edit_event?(@event)
      redirect_to events_path, alert: "Keine Berechtigung."
    end
  end
  
  def check_admin_permissions
    redirect_to events_path, alert: "Nur Admins dürfen das." unless current_user.admin?
  end
  
  def check_online_offline_permissions
    unless can_edit_event?(@event)
      redirect_to events_path, alert: "Keine Berechtigung."
    end
  end
  
  def can_edit_event?(event)
    return true if current_user.admin?
    return false unless current_user.organization?
    event.organization_id == current_user.organization&.id
  end
end