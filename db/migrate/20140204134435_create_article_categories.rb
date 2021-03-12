class CreateArticleCategories < ActiveRecord::Migration
  def change
    create_table :article_categories do |t|
      t.timestamps

      t.string :name, null: false
    end
  end
end
