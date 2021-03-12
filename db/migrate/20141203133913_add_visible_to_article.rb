class AddVisibleToArticle < ActiveRecord::Migration
  def change
    add_column :articles, :visible, :boolean, default: true, null: false, index: true
  end
end
