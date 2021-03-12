class Admin::VisitsController < ApplicationController
  include AdminController

  USER_SEARCH_LIMIT = 15
  LOGS_PERIOD = 1.month

  before_action :load_location, only: [:index, :create]
  before_action :build_visit, only: [:index, :create]
  before_action :load_visit, only: [:finish]
  before_action :load_visits, only: [:index]

  def index
    respond_to do |format|
      format.html do
        load_card_scans_shortlog
      end

      format.json do
        visits_json = @visits.map do |visit|
          {
            html: render_to_string('admin/visits/_visit.html', layout: false, locals: {visit: visit}),
            id: visit.id
          }
        end

        render json: visits_json
      end
    end
  end

  def logs
    @period_end = Date.today.end_of_day
    @period_start = @period_end - LOGS_PERIOD

    @pagy, @records = pagy(Visit.includes(:user).where(started_at: @period_start..@period_end).order('started_at DESC'), items: 100)
    @records = VisitDecorator.decorate_collection(@records)
  end

  def create
    @visit.started_at = DateTime.now

    if @visit.save
      render json: { success: true }
    else
      flash.now[:alert] = "#{t_action_flash(:alert)} (#{@visit.errors.full_messages.to_sentence})"
      render json: { success: false, flash: render_to_string('layouts/shared/_top_flash.html', layout: false) }
    end
  end

  def finish
    @visit.finish!

    render json: { success: true }
  end

  def search_user_by_name
    name_pattern = "#{params[:name]}%"

    users = User.active.
                 not_visiting.
                 with_role(:user).
                 where('firstname ILIKE ? OR lastname ILIKE ?', name_pattern, name_pattern).
                 limit(USER_SEARCH_LIMIT)

    render json: UsersDecorator.decorate(users).as_json_for_autocomplete
  end

  private

  def visit_params
    if params.key?(:visit)
      params[:visit].delete(:user_name)
      params[:visit].permit(:user_id, :location)
    else
      {}
    end
  end

  def load_visit
    @visit = Visit.find(params[:id])
  end

  def build_visit
    @visit = Visit.new(visit_params)
  end

  def load_visits
    @visits = Visit.in_progress
                    .includes(:user)
                    .where(location: @location).order('users.firstname ASC, users.lastname ASC')
                    .decorate
  end

  def load_card_scans_shortlog
    @card_scans = CardScan.
                    includes(:user).
                    where(location: @location).
                    order('scanned_at DESC').
                    limit(Admin::CardScansController::CARD_SCANS_SHORTLOG_LIMIT).
                    decorate
  end

  def load_location
    @location = params[:location].present? ? params[:location] : current_user.location
  end
end
