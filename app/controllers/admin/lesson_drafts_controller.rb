class Admin::LessonDraftsController < ApplicationController
  include AdminController

  before_action :build_lesson_draft, only: [:new, :create]
  before_action :load_lesson_draft, only: [:edit, :update, :destroy]
  before_action :load_location, only: [:index]

  def index
    respond_to do |format|
      format.html

      format.json do
        @lessons = LessonDraft.where(location: @location).
                    pluck(:id, :start_at_hour, :end_at_hour, :activity, :room, :max_spots, :weekday)

        render json: @lessons.map {|lesson| LessonDraft.json_format(lesson) }
      end
    end
  end

  def show
    @lesson = LessonDraft.find(params[:id]).decorate
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
    if @lesson_draft.save
      render json: {
        success: true
      }
    else
      render json: {
        success: false,
        html_content: render_to_string('admin/lesson_drafts/new_modal', layout: false)
      }
    end
  end

  def edit
    render 'edit_modal', layout: false
  end

  def update
    if @lesson_draft.update_attributes(lesson_draft_params)
      render json: {
        success: true
      }
    else
      render json: {
        success: false,
        html_content: render_to_string('admin/lesson_drafts/edit_modal', layout: false)
      }
    end
  end

  def destroy
    @lesson_draft.destroy
    render json: { success: true }
  end

  private

  def load_location
    @location = params[:location].present? ? params[:location] : current_user.location
  end

  def build_lesson_draft
    @lesson_draft = LessonDraft.new(lesson_draft_params)
  end

  def load_lesson_draft
    @lesson_draft = LessonDraft.find(params[:id])
  end

  def lesson_draft_params
    if params.key?(:lesson_draft)
      params.
        require(:lesson_draft).
        permit(:room, :coach_name, :activity, :weekday, :start_at_hour, :end_at_hour, :max_spots, :location)
    else
      {}
    end
  end
end
