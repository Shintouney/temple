class CreateArticles < ActiveRecord::Migration
  def change
    create_table :articles do |t|
      t.timestamps

      t.references :article_category

      t.decimal :price_ati, precision: 8, scale: 2, null: false
      t.decimal :price_te, precision: 8, scale: 2, null: false
      t.decimal :taxes_rate, precision: 5, scale: 2, null: false

      t.string :name, null: false
      t.text :description
    end
  end
end
