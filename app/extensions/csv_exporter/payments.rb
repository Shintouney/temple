# encoding: UTF-8
include ActionView::Helpers::NumberHelper
require 'fileutils'

module CSVExporter
  class Payments < Base
    COLUMNS = {
      created_at: I18n.t('admin.exports.payments.charge_at'),
      updated_at: Payment.human_attribute_name(:updated_at),
      paybox_transaction: Payment.human_attribute_name(:paybox_transaction),
      state: Payment.human_attribute_name(:state),
      comment: Payment.human_attribute_name(:comment),
      end_at: I18n.t('admin.exports.payments.issue_date'),
      user_firstname: User.human_attribute_name(:firstname),
      user_lastname: User.human_attribute_name(:lastname),
      total_price_ati: Invoice.human_attribute_name(:total_price_ati),
      total_price_te: I18n.t('admin.exports.payments.total_price_te'),
      location: Order.human_attribute_name(:location),
    }

    def initialize(export)
      @export = export
    end

    def execute
      csv_string = ""
      FileUtils.mkdir_p 'tmp/exports'
      begin
        @elements_to_csv = @export.payments
        csv_string = CsvShaper::Shaper.encode do |csv_content|
                      headers(csv_content)
                      rows(csv_content)
                     end
        File.open(@export.path, 'w') { |file| file.write("\xEF\xBB\xBF" + csv_string) }
        @export.complete!
      rescue StandardError => e
        @export.destroy
        Raven.capture_exception(e)
      ensure
        @export.progress_tracker.delete
      end
      csv_string
    end

    private

    def headers(csv)
      csv.headers do |csv_header|
        map_headers
        csv_header.columns(*COLUMNS.keys)
        csv_header.mappings COLUMNS
      end
    end

    def map_headers
      COLUMNS.merge!('category_subscription_plan'.to_sym => I18n.t('admin.exports.invoices.subscription_plan_total_price_te'))

      map_headers_article_category

      #COLUMNS.merge!(:unknown => I18n.t('admin.exports.invoices.category_total_price_te', category_name: 'unknown', tax_rate: 'unknown'))

      OrderItem.pluck(:product_taxes_rate).uniq.sort { |x, y| y <=> x }.each do |tax_rate|
        COLUMNS.merge!(I18n.t('admin.exports.invoices.taxes_rate', rate: number_to_percentage(tax_rate, precision: 2)) => "#{tax_rate}")
      end
    end

    def map_headers_article_category
      ArticleCategory.all.each do |category|
        OrderItem.pluck(:product_taxes_rate).uniq.sort { |x, y| y <=> x }.each do |tax_rate|
          COLUMNS.merge!("#{category.name}_#{tax_rate}".to_sym => I18n.t('admin.exports.invoices.category_total_price_te', category_name: category.name,
                                                                          tax_rate: tax_rate))
        end
      end      
    end

    def rows(csv)
      csv.rows elements_to_csv do |csv_row, payment|
        invoice = payment.invoices.first.decorate

        csv_row.cell :end_at, invoice.end_at
        csv_row.cell :user_firstname, invoice.user_firstname
        csv_row.cell :user_lastname, invoice.user_lastname
        csv_row.cell :state, invoice.state
        csv_row.cell :total_price_ati, invoice.total_price_ati
        csv_row.cell :total_price_te, invoice.total_price_te
        csv_row.cell :location, invoice.temple_location

        csv_row.cells :created_at, :updated_at, :user_id, :price, :paybox_transaction, :state, :comment
        map_extra_models(csv_row, invoice)
        @export.progress_tracker.increment_processed_items
      end
    end

    def map_extra_models(csv_row, invoice)
      csv_row.cell 'category_subscription_plan', invoice.subscription_plan_order_item_price_te

      invoice.prices_te_by_articles_categories_and_taxes.each do |category_name, price|
        csv_row.cell "#{category_name}".to_sym, price
      end

      invoice.taxes_amounts.each do |tax_rate, tax_amount|
        csv_row.cell I18n.t('admin.exports.invoices.taxes_rate', rate: tax_rate), tax_amount
      end
    end
  end
end
