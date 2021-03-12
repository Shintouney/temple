class Admin::LessonTemplatesController < ApplicationController
  include AdminController

  before_action :build_lesson_template, only: [:new, :create]
  before_action :load_lesson_template, only: [:edit, :update, :destroy]
  before_action :load_location, only: [:index]

  def index
    respond_to do |format|
      format.html

      format.json do
        @lessons = LessonTemplate.where(location: @location).
                    pluck(:id, :start_at_hour, :end_at_hour, :activity, :room, :max_spots, :weekday)

        render json: @lessons.map {|lesson| LessonTemplate.json_format(lesson) }
      end
    end
  end

  def show
    @lesson = LessonTemplate.find(params[:id]).decorate
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
    if @lesson_template.save
      render json: {
        success: true
      }
    else
      render json: {
        success: false,
        html_content: render_to_string('admin/lesson_templates/new_modal', layout: false)
      }
    end
  end

  def edit
    render 'edit_modal', layout: false
  end

  def update
    if @lesson_template.update_attributes(lesson_template_params)
      render json: {
        success: true
      }
    else
      render json: {
        success: false,
        html_content: render_to_string('admin/lesson_templates/edit_modal', layout: false)
      }
    end
  end

  def destroy
    @lesson_template.destroy

    render json: { success: true }
  end

  private

  def load_location
    @location = params[:location].present? ? params[:location] : current_user.location
  end

  def build_lesson_template
    @lesson_template = LessonTemplate.new(lesson_template_params)
  end

  def load_lesson_template
    @lesson_template = LessonTemplate.find(params[:id])
  end

  def lesson_template_params
    if params.key?(:lesson_template)
      params.
        require(:lesson_template).
        permit(:room, :coach_name, :activity, :weekday, :start_at_hour, :end_at_hour, :max_spots, :location)
    else
      {}
    end
  end
end
