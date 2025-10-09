class UniversitiesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_university, only: [:show, :edit, :update, :release, :lock]

  def index
    if current_user.admin?
      @universities = University.all
    elsif current_user.university_staff?
      # University staff can see university management interface
      @university = current_user.university
      redirect_to university_path(@university) if @university
    elsif current_user.university?
      # Regular students are redirected to their university's show page
      @university = current_user.university
      redirect_to university_path(@university) if @university
    else
      redirect_to root_path, alert: 'Access denied'
    end
  end

  def show
    # Students and staff can view their university
    if current_user.admin?
      # Admin can view any university
    elsif current_user.university?
      # Check if user belongs to this university
      unless @university == current_user.university
        redirect_to root_path, alert: 'Access denied'
        return
      end
    else
      redirect_to root_path, alert: 'Access denied'
      return
    end
  end

  def edit
    # Only university staff and admins can edit
    unless current_user.admin? || (current_user.university_staff? && @university == current_user.university)
      redirect_to university_path(@university), alert: 'You are not authorized to edit this university'
    end
  end

  def update
    unless current_user.admin? || (current_user.university_staff? && @university == current_user.university)
      redirect_to university_path(@university), alert: 'You are not authorized to edit this university'
      return
    end

    if @university.update(university_params)
      redirect_to university_path(@university), notice: 'University was successfully updated.'
    else
      render :edit
    end
  end

  def release
    if current_user.admin?
      @university.update(released: true)
      redirect_to universities_path, notice: 'University was successfully released.'
    else
      redirect_to universities_path, alert: 'Access denied'
    end
  end

  def lock
    if current_user.admin?
      @university.update(released: false)
      redirect_to universities_path, notice: 'University was successfully locked.'
    else
      redirect_to universities_path, alert: 'Access denied'
    end
  end

  private

  def set_university
    @university = University.find(params[:id])
  end

  def university_params
    params.require(:university).permit(:name, :email, :contact_number, :website, :description, :logo)
  end
end
