class RenameCurrentPeriodInvoiceIdToCurrentDeferredPeriodInvoiceIdFromUsers < ActiveRecord::Migration
  def change
    rename_column :users, :current_period_invoice_id, :current_deferred_invoice_id
  end
end
