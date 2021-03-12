require 'acceptance/acceptance_helper'

feature 'Admin Article management', type: :feature do
  context "logged in as an admin" do
    before { login_as(:admin) }

    let!(:articles) { FactoryBot.create_list(:article, 2) }

    let(:article_attributes) { FactoryBot.attributes_for(:article) }

    let(:image_file) do
      Rails.root.join('spec/fixtures/images/logo_novagile.png')
    end

    scenario 'Accessing the index' do
      visit admin_articles_path

      expect(page).to have_text(articles.first.name)
      expect(page.all('table tbody tr').length).to eql(2)
    end

    scenario 'Creating an article' do
      article_attributes = FactoryBot.attributes_for(:article, article_category: nil)
      articles_count = Article.count

      visit admin_articles_path
      click_link 'new_article'

      fill_in 'article_name', with: article_attributes[:name]
      fill_in 'article_price_ati', with: article_attributes[:price_ati]
      fill_in 'article_price_te', with: article_attributes[:price_te]
      fill_in 'article_taxes_rate', with: article_attributes[:taxes_rate]
      attach_file('article_image', image_file)

      click_button 'article_submit'

      expect(current_path).to eql(admin_articles_path)
      assert_flash_presence 'admin.articles.create.notice'

      expect(Article.count).to eql(articles_count + 1)
      expect(Article.last.name).to eql(article_attributes[:name])
    end

    scenario 'Failing to create an article' do
      articles_count = Article.count

      visit admin_articles_path
      click_link 'new_article'

      click_button 'article_submit'

      expect(current_path).to eql(admin_articles_path)

      expect(Article.count).to eql(articles_count)
    end

    scenario 'Editing an article' do
      new_name = "name2"
      visit edit_admin_article_path(articles.first)

      fill_in 'article_name', with: new_name
      click_button 'article_submit'

      expect(current_path).to eql(admin_articles_path)
      assert_flash_presence 'admin.articles.update.notice'

      expect(articles.first.reload.name).to eql(new_name)
    end

    scenario 'Failing to edit an article' do
      visit edit_admin_article_path(articles.first)

      fill_in 'article_name', with: ''
      click_button 'article_submit'

      assert_flash_presence 'admin.articles.update.alert'
      expect(page).to have_css("#edit_article_#{articles.first.id}")
    end

    scenario 'Deleting an article' do
      visit admin_articles_path
      expect(page).to have_css(".fa-eye")

      expect(page).to have_css("#destroy_article_#{articles.last.id}")
      expect(page).to have_css("#destroy_article_#{articles.last.id}.btn-default")
      click_link "destroy_article_#{articles.last.id}"
      expect(current_path).to eql(admin_articles_path)
      assert_flash_presence 'admin.articles.destroy.notice'
      expect(page).to have_css("#destroy_article_#{articles.last.id}.btn-danger")
      expect(page).to have_css(".fa-eye-slash")
      articles.last.reload
      assert_equal articles.last.reload.visible, false
    end
  end

  context "logged in as a user" do
    before { login_as(:user) }

    scenario 'Accessing the index' do
      visit admin_articles_path

      expect(current_path).not_to eql(admin_articles_path)
      assert_flash_presence 'access_denied'
    end
  end
end
