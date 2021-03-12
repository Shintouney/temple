class Admin::LessonsController < ApplicationController
  include AdminController

  before_action :build_lesson, only: [:new, :create]
  before_action :load_lesson, only: [:edit, :update, :destroy]
  before_action :load_location, only: [:index]

  def index
    respond_to do |format|
      format.html

      format.json do
        @lessons = Lesson.all
        @lessons = @lessons.within_period(params[:start], params[:end]) if params[:start].present? || params[:end].present?
        @lessons = @lessons.where(location: params[:location]) if params[:location].present?
        @lessons = @lessons.pluck(:id, :start_at, :end_at, :activity, :room, :max_spots)

        render json: @lessons.map { |lesson| Lesson.json_format(lesson) }
      end
    end
  end

  def show
    @lesson = Lesson.find(params[:id]).decorate
    respond_to do |format|
      format.json do
        render json: @lesson.to_json
      end
    end
  end

  def new
    render 'new_modal', layout: false
  end

  def create
    if @lesson.save
      render json: { success: true }
    else
      render json: {
        success: false,
        html_content: render_to_string('admin/lessons/new_modal', layout: false)
      }
    end
  end

  def edit
    render 'edit_modal', layout: false
  end

  def update
    @lesson.max_spots = lesson_params[:max_spots]
    max_spots_changed = @lesson.max_spots_changed?

    if @lesson.update_attributes(lesson_params)
      User::SendLessonNotifications.new(@lesson).execute if max_spots_changed

      render json: { success: true }
    else
      render json: {
        success: false,
        html_content: render_to_string('admin/lessons/edit_modal', layout: false)
      }
    end
  end

  def destroy
    @lesson.lesson_bookings.each do |booking|
      UserMailer.lesson_canceled(booking.user_id, @lesson.start_at, @lesson.end_at, @lesson.coach_name, @lesson.activity).deliver_later
      booking.destroy
    end
    NotificationSchedule.where(lesson_id: @lesson.id).destroy_all
    @lesson.destroy
    render json: { success: true }
  end

  private
  def load_location
    @location = params[:location].present? ? params[:location] : current_user.location
  end

  def build_lesson
    @lesson = Lesson.new(lesson_params)
  end

  def load_lesson
    @lesson = Lesson.find(params[:id]).decorate
  end

  def lesson_params
    if params.key?(:lesson)
      params.
        require(:lesson).
        permit(:room, :coach_name, :activity, :start_at, :end_at, :cancelled, :max_spots, :location)
    else
      {}
    end
  end
end
