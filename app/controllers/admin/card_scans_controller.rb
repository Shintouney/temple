class Admin::CardScansController < ApplicationController
  include AdminController

  before_action :load_location

  LOGS_PERIOD = 2.weeks

  CARD_SCANS_SHORTLOG_LIMIT = 10

  def index
    @period_end = Date.today.end_of_day
    @period_start = @period_end - LOGS_PERIOD

    @pagy, @records = pagy(CardScan.includes(:user).where(scanned_at: @period_start..@period_end).order('scanned_at DESC'), items: 100)
    @records = CardScanDecorator.decorate_collection(@records)
  end

  def shortlog
    respond_to do |format|
      format.json do
        @card_scans = CardScan.includes(:user).where(location: @location).order('scanned_at DESC').limit(CARD_SCANS_SHORTLOG_LIMIT).decorate

        card_scans_json = @card_scans.map do |card_scan|
          {
            html: render_to_string('admin/visits/_card_scan.html', layout: false, locals: {card_scan: card_scan}),
            id: card_scan.id
          }
        end

        render json: card_scans_json
      end
    end
  end

  private
  def load_location
    @location = params[:location].present? ? params[:location] : 'moliere'
  end
end
