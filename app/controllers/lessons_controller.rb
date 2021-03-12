class LessonsController < ApplicationController

  before_action :require_login
  before_action :load_lesson, only: [:show]

  def index
    @location = params[:location].present? ? params[:location] : 'moliere'

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
      format.html do
        render 'show_modal', layout: false
      end

      format.json do
        render json: @lesson.to_json
      end
    end
  end

  private

  def load_lesson
    lesson = Lesson.where(id: params[:id])
    @lesson = LessonDecorator.decorate(lesson.first) if lesson.present?
  end
end
