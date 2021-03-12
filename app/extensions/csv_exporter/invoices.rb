# encoding: UTF-8
include ActionView::Helpers::NumberHelper
require 'fileutils'

module CSVExporter
  class Invoices < Base
    COLUMNS = {
      id: I18n.t('admin.exports.invoices.invoice_number'),
      created_at: I18n.t('admin.exports.invoices.issue_date'),
      end_at: I18n.t('admin.exports.invoices.due_date'),
      payed_at: I18n.t('admin.exports.invoices.payed_at'),
      user_firstname: User.human_attribute_name(:firstname),
      user_lastname: User.human_attribute_name(:lastname),
      billing_name: User.human_attribute_name(:billing_name),
      billing_address: User.human_attribute_name(:billing_address),
      state: ::Invoice.human_attribute_name(:state),
      paybox_transaction: Payment.human_attribute_name(:paybox_transaction),
      total_price_ati: ::Invoice.human_attribute_name(:total_price_ati),
      total_price_te: I18n.t('admin.exports.invoices.total_price_te')
    }

    def initialize(export)
      @export = export
    end

    def execute
      csv_string = ""
      FileUtils.mkdir_p 'tmp/exports'
      begin
        @elements_to_csv = @export.invoices
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

      #COLUMNS.merge!(:unknown => I18n.t('admin.exports.invoices.category_total_price_te', category_name: 'unknown'))

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
      csv.rows elements_to_csv do |csv_row, invoice|
        map_cells_rows(csv_row, invoice)
        @export.progress_tracker.increment_processed_items
      end
    end

    def map_cells_rows(csv_row, invoice)
      csv_row.cells :id, :created_at, :end_at, :total_price_ati, :billing_name, :billing_address
      csv_row.cell :total_price_te, invoice.total_price_te
      csv_row.cell :payed_at, invoice.accepted_payment.created_at if invoice.accepted_payment.present?

      map_extra_models(csv_row, invoice)

      csv_row.cell :state, invoice.state
      csv_row.cell :user_firstname, invoice.user.firstname
      csv_row.cell :user_lastname, invoice.user.lastname
      csv_row.cell :paybox_transaction, invoice.paybox_transaction_number
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
