# encoding: UTF-8
class Admin::ExportsController < ApplicationController
  include AdminController

  before_action :date_filter, only: [:create, :order_items, :payments]
  before_action :visits_filter, only: :visits
  before_action :init_dates_display, only: :index

  def index
    @exports = Export.where(state: 'completed').order('created_at DESC').reduce([]) do |acc, export|
      acc << export unless acc.select{|exp| exp.subtype == export.subtype }.any?
      acc
    end
    @current_exports = Export.in_progress
    @cbusers = User.active.with_payment_mode(:cb).count
    @sepausers = User.active.with_payment_mode(:sepa).count
  end

  def create
    export = Export.create!(export_type: export_params[:export_type],
                            subtype: export_params[:subtype],
                            date_start: @date_filter_start,
                            date_end: @date_filter_end)
    ExportWorker.perform_async(export.id)
    redirect_to admin_exports_path, notice: t_action_flash(:notice)
  end

  def show
    @export = Export.find(params[:id])
    send_file(@export.path,
              type: 'text/csv; charset=utf-8; header=present',
              disposition: "attachment",
              filename: @export.filename)
  end

  def progress
    @export = Export.find_by_id(params[:id])
    render text: @export.present? ? @export.progress_tracker.progress_percentage : 100
  end

  def refresh_link
    export = Export.where(export_type: export_params[:type], state: 'completed', subtype: export_params[:subtype]).order('created_at DESC').first
    if export.present?
      render json: { success: true, url: admin_export_path(export), name: "#{export.filename} (##{export.id})" }
    else
      render json: { success: false }
    end
  end

  def order_items
    @order_items = OrderItem.where(product_type: 'Article')
                            .where("created_at >= ? AND created_at <= ?", @date_filter_start, @date_filter_end)
                            .includes(product: :article_category)
                            .order(:created_at)
                            .decorate
    respond_to do |format|
      format.csv do
        @filename = t('.csv_filename', date: Date.today.to_formatted_s(:db))
        csv_string = CSVExporter::OrderItems.new(@order_items).execute
        send_csv(csv_string)
      end
    end
  end

  def visits
    @visits = Visit.where("started_at >= ? AND started_at <= ?", @date_filter_visits_start, @date_filter_visits_end).includes(:user)
    respond_to do |format|
      format.csv do
        @filename = t('.csv_filename', date: @date_filter_visits_start.to_date.to_formatted_s(:db))
      end
    end
  end

  def subscriptions
    @subscriptions = Subscription.all.includes(:user, :subscription_plan).order('updated_at DESC').decorate
    respond_to do |format|
      format.csv do
        @filename = t('.csv_filename', date: Date.today.to_formatted_s(:db))
        csv_string = CSVExporter::Subscriptions.new(@subscriptions).execute
        send_csv(csv_string)
      end
    end
  end

  def red_list
    @users = User.red_list
    respond_to do |format|
      format.csv do
        @filename = t('.csv_filename', date: Date.today.to_formatted_s(:db))
      end
    end
  end

  private

  def export_params
    params.require(:export).permit :export_type, :type, :subtype, :state, :date_start, :date_end
  end

  def init_dates_display
    @date_filter_start = Date.today.advance(months: -1).strftime('%d/%m/%Y')
    @date_filter_end = Date.today.strftime('%d/%m/%Y')
    @date_filter_visits_start = Date.today.advance(weeks: -2).strftime('%d/%m/%Y')
    @date_filter_visits_end = Date.today.strftime('%d/%m/%Y')
  end

  def date_filter
    @date_filter_start = Time.zone.parse("#{export_params[:date_start]}") || Date.today.advance(months: -1)
    @date_filter_start = @date_filter_start.beginning_of_day() if @date_filter_start.is_a?(Time)
    @date_filter_end = Time.zone.parse("#{export_params[:date_end]}") || Date.today
    @date_filter_end = @date_filter_end.end_of_day() if @date_filter_end.is_a?(Time)
  end

  def visits_filter
    begin
      @date_filter_visits_start = Time.zone.parse("#{params[:visits_date_start]}") || Date.today.advance(weeks: -2)
      @date_filter_visits_start = @date_filter_visits_start.beginning_of_day() if @date_filter_visits_start.is_a?(Time)
      @date_filter_visits_end = Time.zone.parse("#{params[:visits_date_end]}") || Date.today
      @date_filter_visits_end = @date_filter_visits_end.end_of_day() if @date_filter_visits_end.is_a?(Time)
    rescue ArgumentError => e
      redirect_to admin_exports_path, alert: t_action_flash(:alert)
    end
  end
end
