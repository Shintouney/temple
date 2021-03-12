class AddBillingAddressToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :billing_address, :string

    # Invoice.all.each do |invoice|
    #   update_attribute(:billing_name, invoice.user.billing_name) if invoice.user.billing_name.present?  
    #   update_attribute(:billing_address, invoice.user.billing_address) if invoice.user.billing_address.present?  
    # end
  end
end
