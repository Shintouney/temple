require 'acceptance/acceptance_helper'

feature 'Admin ArticleCategory management' do
  context "logged in as an admin" do
    before { login_as(:admin) }

    let!(:article_categories) { FactoryBot.create_list(:article_category, 2) }

    scenario 'Accessing the index' do
      visit admin_article_categories_path

      expect(page).to have_text(article_categories.first.name)
      expect(page.all('table tbody tr').length).to eql(2)
    end

    scenario 'Creating an article_category' do
      name = "Category name"
      article_categories_count = ArticleCategory.count

      visit admin_article_categories_path
      click_link 'new_article_category'

      fill_in 'article_category_name', with: name
      click_button 'article_category_submit'

      expect(current_path).to eql(admin_article_categories_path)
      assert_flash_presence 'admin.article_categories.create.notice'

      expect(ArticleCategory.count).to eql(article_categories_count + 1)
      expect(ArticleCategory.last.name).to eql(name)
    end

    scenario 'Failing to create an article_category' do
      article_categories_count = ArticleCategory.count

      visit admin_article_categories_path
      click_link 'new_article_category'

      click_button 'article_category_submit'

      expect(current_path).to eql(admin_article_categories_path)

      expect(ArticleCategory.count).to eql(article_categories_count)
    end

    scenario 'Editing an article_category' do
      new_name = "name2"
      visit edit_admin_article_category_path(article_categories.first)

      fill_in 'article_category_name', with: new_name
      click_button 'article_category_submit'

      expect(current_path).to eql(admin_article_categories_path)
      assert_flash_presence 'admin.article_categories.update.notice'

      expect(article_categories.first.reload.name).to eql(new_name)
    end

    scenario 'Failing to edit an article_category' do
      visit edit_admin_article_category_path(article_categories.first)

      fill_in 'article_category_name', with: ''
      click_button 'article_category_submit'

      assert_flash_presence 'admin.article_categories.update.alert'
      expect(page).to have_css("#edit_article_category_#{article_categories.first.id}")
    end

    scenario 'Deleting an article_category' do
      visit admin_article_categories_path

      click_link "destroy_article_category_#{article_categories.first.id}"

      expect(current_path).to eql(admin_article_categories_path)
      assert_flash_presence 'admin.article_categories.destroy.notice'

      expect(ArticleCategory.exists?(article_categories.first.id)).to be false
    end
  end

  context "logged in as a user" do
    before { login_as(:user) }

    scenario 'Accessing the index' do
      visit admin_article_categories_path

      expect(current_path).not_to eql(admin_article_categories_path)
      assert_flash_presence 'access_denied'
    end
  end
end
