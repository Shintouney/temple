require 'rails_helper'

describe Admin::ArticlesController, type: :controller do
  before { login_user(FactoryBot.create(:admin)) }

  let!(:article) { FactoryBot.create :article }

  describe 'DELETE article' do
    it 'makes the article invisible for admin' do
      expect do
        delete :destroy, id: article.id
        article.reload
      end.to change(article, :visible).from(true).to(false)
    end
    it 'redirects to articles list' do
      delete :destroy, id: article.id
      expect(response).to redirect_to admin_articles_path
    end
  end
end
