class AddIndexCommentToPayments < ActiveRecord::Migration
  def change
    add_index :payments, :comment
  end
end
