# encoding: UTF-8
class ExportWorker
  include Sidekiq::Worker

  sidekiq_options retry: false

  def perform(export_id)
    export = Export.find(export_id)
    case export.export_type
    when 'invoice'
      CSVExporter::Invoices.new(export).execute
    when 'lesson_booking'
      CSVExporter::LessonBookings.new(export).execute
    when 'payment'
      CSVExporter::Payments.new(export).execute
    when 'user'
      CSVExporter::Users.new(export).execute
    end
  end
end
