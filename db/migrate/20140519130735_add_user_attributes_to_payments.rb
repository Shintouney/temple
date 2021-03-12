class AddUserAttributesToPayments < ActiveRecord::Migration
  def up
    change_table :payments do |t|
      t.string :user_firstname
      t.string :user_lastname
      t.string :user_street1
      t.string :user_street2
      t.string :user_postal_code
      t.string :user_city
    end

    Payment.all.each do |payment|
      next unless payment.user

      payment.update_attribute :user_firstname, payment.user.firstname
      payment.update_attribute :user_lastname, payment.user.lastname
      payment.update_attribute :user_street1, payment.user.street1
      payment.update_attribute :user_street2, payment.user.street2
      payment.update_attribute :user_postal_code, payment.user.postal_code
      payment.update_attribute :user_city, payment.user.city
    end
  end

  def down
    change_table :payments do |t|
      t.remove :user_firstname
      t.remove :user_lastname
      t.remove :user_street1
      t.remove :user_street2
      t.remove :user_postal_code
      t.remove :user_city
    end
  end
end
