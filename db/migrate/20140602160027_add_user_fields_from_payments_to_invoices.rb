class AddUserFieldsFromPaymentsToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :user_id, :integer
    add_column :invoices, :user_firstname, :string
    add_column :invoices, :user_lastname, :string
    add_column :invoices, :user_street1, :string
    add_column :invoices, :user_street2, :string
    add_column :invoices, :user_postal_code, :string
    add_column :invoices, :user_city, :string
  end
end
