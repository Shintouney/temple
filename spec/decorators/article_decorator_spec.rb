require 'rails_helper'

describe ArticleDecorator do
  let(:article_decorator) { FactoryBot.build_stubbed(:article).decorate }

  describe '#price_ati' do
    before do
      article_decorator.object.price_ati = 20
    end

    describe '#price_ati' do
      it { expect(article_decorator.price_ati).to match('20') }
    end
  end

  describe '#name_for_select' do
    before do
      article_decorator.object.price_ati = 30
      article_decorator.object.name = "Cola"
    end

    describe '#name_for_select' do
      it { expect(article_decorator.name_for_select).to match("Cola                              - 30,00 €") }      
    end
  end
end
