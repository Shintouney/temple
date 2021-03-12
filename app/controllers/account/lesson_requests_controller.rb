class Account::LessonRequestsController < ApplicationController
  include AccountController

  def new
    @lesson_request = LessonRequest.new
  end

  def create
    @lesson_request = LessonRequest.new(lesson_request_params)

    if @lesson_request.save
      AdminMailer.lesson_request_notification(@lesson_request.id).deliver_later
      redirect_to new_account_lesson_request_path, notice: t('.notice')
    else
      render action: 'new'
    end
  end

  private
  def lesson_request_params
    params.require(:lesson_request).permit(:first_coach_name,
                                      :second_coach_name,
                                      :comment,
                                      :user_id)
  end
end
