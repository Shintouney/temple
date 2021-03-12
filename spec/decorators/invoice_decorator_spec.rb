require 'rails_helper'

describe InvoiceDecorator do
  let(:invoice) { FactoryBot.create(:invoice) }
  subject { InvoiceDecorator.decorate(invoice) }

  describe '#reference' do
    describe '#reference' do
      it { expect(subject.reference).to eql(subject.object.id.to_s) }
    end
  end

  describe '#state' do
    describe '#state' do
      it { expect(subject.state).to eql(subject.aasm.human_state) }
    end
  end

  describe '#state_label_class' do
    let(:invoice) { FactoryBot.create(:invoice) }

    context "for an invoice in the default open state" do
      describe '#state_label_class' do
        it { expect(subject.state_label_class).to eql('label-default') }
      end
    end

    context "for a paid invoice" do
      before do
        invoice.wait_for_payment!
        invoice.accept_payment!
      end

      describe '#state_label_class' do
        it { expect(subject.state_label_class).to eql('label-success') }
      end
    end

    context "for an invoice pending a payment retry" do
      before do
        invoice.wait_for_payment!
        invoice.wait_for_payment_retry!
      end

      describe '#state_label_class' do
        it { expect(subject.state_label_class).to eql('label-danger') }
      end
    end
  end

  describe '#user_full_name' do
    describe '#user_full_name' do
      it { expect(subject.user_full_name).to eql(invoice.billing_name) }
    end

    it "should fetch the full_name when no billing_name" do
      subject.billing_name = nil

      expect(subject.user_full_name).to eql("#{invoice.user_firstname} #{invoice.user_lastname}")
    end
  end

  describe '#accepted_payment' do
    let!(:user) { create_subscribed_user }

    context "with a paid invoice" do
      before do
        invoice.wait_for_payment!

        failed_payment = Payment.new(invoices: [invoice], user: user, credit_card: user.current_credit_card)
        failed_payment.decline!

        accepted_payment = Payment.new(invoices: [invoice], user: user, credit_card: user.current_credit_card)
        accepted_payment.accept!

        invoice.accept_payment!
      end

      it "should fetch the accepted payment for the invoice" do
        expect(subject.accepted_payment).to be_a(PaymentDecorator)
        expect(subject.accepted_payment.state).to eql('accepted')
      end
    end

    context "with an unpaid invoice" do
      let(:invoice) { FactoryBot.create(:invoice, state: 'pending_payment') }

      it "should return nil" do
        expect(subject.accepted_payment).to be_nil
      end
    end
  end

  describe '#end_at' do
    let(:invoice) { FactoryBot.create(:invoice, end_at: '2014-09-07') }

    describe '#end_at' do
      it { expect(subject.end_at).to eql('07/09/2014') }
    end
  end

  describe '#total_price_ati' do
    context "with an invoice with a state other than :open" do
      before do
        subject.object.wait_for_payment!
        subject.object.total_price_ati = 20
      end

      describe '#total_price_ati' do
        it { expect(subject.total_price_ati).to match('20') }
      end
    end

    context "with an invoice who's got a state :open" do
      describe '#total_price_ati' do
        it { expect(subject.total_price_ati).to match(I18n.t('admin.invoices.index.total_price_ati_will_be_computed')) }
      end
    end
  end

  describe '#total_price_te' do
    let!(:orders) { FactoryBot.create_list(:order, 2, user: invoice.user, invoice: invoice) }
    let(:article) { FactoryBot.create(:article, price_te: 13) }

    context "with an invoice with a state other than :open" do
      before do
        Order::AddProduct.new(orders.first, article).execute
        Order::AddProduct.new(orders.last, article).execute

        invoice.wait_for_payment!
      end

      it "should sum and decorate the total_price_te" do
        expect(subject.total_price_te).to eql('26,00 €')
      end
    end

    context "with an invoice who's got a state :open" do
      describe '#total_price_te' do
        it { expect(subject.total_price_te).to match(I18n.t('admin.invoices.index.total_price_ati_will_be_computed')) }
      end
    end
  end

  describe '#taxes_amounts' do
    let!(:products) do
      [
        FactoryBot.create(:article, price_ati: 120, price_te: 100, taxes_rate: 20),
        FactoryBot.create(:article, price_ati: 60, price_te: 50, taxes_rate: 20),
        FactoryBot.create(:article, price_ati: 94.95, price_te: 90, taxes_rate: 5.5),
      ]
    end

    before do
      Invoice::AddArticles.new(invoice, products.map(&:id)).tap(&:execute).order
      Invoice::AddArticles.new(invoice, [products.first.id]).tap(&:execute).order

      invoice.wait_for_payment!
    end

    it "should sum and decorate the taxes amounts" do
      expect(subject.taxes_amounts).to eql('20,00%' => '50,00 €', '5,50%' => '4,95 €')
    end
  end

  describe '#order_items_by_article_categories_and_taxes' do
    let(:invoice) { FactoryBot.create(:invoice) }

    let(:article_category1) { FactoryBot.create(:article_category) }
    let(:article_category2) { FactoryBot.create(:article_category) }
    let(:article1) { FactoryBot.create(:article, article_category: article_category1, taxes_rate: 20.0) }
    let(:article2) { FactoryBot.create(:article, article_category: article_category2, taxes_rate: 20.0) }
    let(:article3) { FactoryBot.create(:article, article_category: article_category1, taxes_rate: 5.5) }
    let(:article4) { FactoryBot.create(:article, article_category: article_category2, taxes_rate: 5.5) }

    before do
      Invoice::AddArticles.new(invoice, [article1.id, article2.id]).execute
      Invoice::AddArticles.new(invoice, [article3.id, article4.id]).execute

      invoice.reload
    end

    it 'creates a Hash categorizing order items by taxes amout' do
      expect(subject.order_items_by_article_categories_and_taxes.keys).to eql ["#{article_category1.name}_#{article1.taxes_rate}",
                                                                               "#{article_category2.name}_#{article2.taxes_rate}",
                                                                               "#{article_category1.name}_#{article3.taxes_rate}",
                                                                               "#{article_category2.name}_#{article4.taxes_rate}"]

      expect(subject.order_items_by_article_categories_and_taxes["#{article_category1.name}_#{article1.taxes_rate}"].map(&:product)).to eql([article1])
      expect(subject.order_items_by_article_categories_and_taxes["#{article_category2.name}_#{article2.taxes_rate}"].map(&:product)).to eql([article2])
      expect(subject.order_items_by_article_categories_and_taxes["#{article_category1.name}_#{article3.taxes_rate}"].map(&:product)).to eql([article3])
      expect(subject.order_items_by_article_categories_and_taxes["#{article_category2.name}_#{article4.taxes_rate}"].map(&:product)).to eql([article4])
    end
  end

  describe '#prices_te_by_articles_categories_and_taxes' do
    let(:invoice) { FactoryBot.create(:invoice) }

    let(:article_category1) { FactoryBot.create(:article_category) }
    let(:article_category2) { FactoryBot.create(:article_category) }
    let(:article1) { FactoryBot.create(:article, article_category: article_category1, price_te: 126.87, taxes_rate: 20.0) }
    let(:article2) { FactoryBot.create(:article, article_category: article_category2, price_te: 28.12, taxes_rate: 20.0) }
    let(:article3) { FactoryBot.create(:article, article_category: article_category1, price_te: 512.56, taxes_rate: 5.5) }
    let(:article4) { FactoryBot.create(:article, article_category: article_category2, price_te: 17.62, taxes_rate: 5.5) }

    before do
      Invoice::AddArticles.new(invoice, [article1.id, article2.id]).execute
      Invoice::AddArticles.new(invoice, [article3.id, article4.id]).execute

      invoice.reload
    end

    it 'creates a Hash categorizing order items prizes' do
      expect(subject.prices_te_by_articles_categories_and_taxes.keys).to eql ["#{article_category1.name}_#{article1.taxes_rate}",
                                                                              "#{article_category2.name}_#{article2.taxes_rate}",
                                                                              "#{article_category1.name}_#{article4.taxes_rate}",
                                                                              "#{article_category2.name}_#{article3.taxes_rate}"]

      expect(subject.prices_te_by_articles_categories_and_taxes["#{article_category1.name}_#{article1.taxes_rate}"]).to match('126.87')
      expect(subject.prices_te_by_articles_categories_and_taxes["#{article_category1.name}_#{article3.taxes_rate}"]).to match('512.56')
      expect(subject.prices_te_by_articles_categories_and_taxes["#{article_category2.name}_#{article2.taxes_rate}"]).to match('28.12')
      expect(subject.prices_te_by_articles_categories_and_taxes["#{article_category2.name}_#{article4.taxes_rate}"]).to match('17.62')
    end
  end

  describe '#order_items_by_article_categories' do
    let(:invoice) { FactoryBot.create(:invoice) }

    let(:article_category1) { FactoryBot.create(:article_category) }
    let(:article_category2) { FactoryBot.create(:article_category) }
    let(:article1) { FactoryBot.create(:article, article_category: article_category1) }
    let(:article2) { FactoryBot.create(:article, article_category: article_category2) }
    let(:article3) { FactoryBot.create(:article, article_category: article_category1) }
    let(:article4) { FactoryBot.create(:article, article_category: article_category2) }

    before do
      Invoice::AddArticles.new(invoice, [article1.id, article2.id]).execute
      Invoice::AddArticles.new(invoice, [article3.id, article4.id]).execute

      invoice.reload
    end

    it 'creates a Hash categorizing order items' do
      expect(subject.order_items_by_article_categories.keys).to eql [article_category1.name, article_category2.name]

      expect(subject.order_items_by_article_categories[article_category1.name].map(&:product)).to eql([article1, article3])
      expect(subject.order_items_by_article_categories[article_category2.name].map(&:product)).to eql([article2, article4])
    end
  end

  describe '#prices_te_by_articles_categories' do
    let(:invoice) { FactoryBot.create(:invoice) }

    let(:article_category1) { FactoryBot.create(:article_category) }
    let(:article_category2) { FactoryBot.create(:article_category) }
    let(:article1) { FactoryBot.create(:article, article_category: article_category1, price_te: 126.87) }
    let(:article2) { FactoryBot.create(:article, article_category: article_category2, price_te: 28.12) }
    let(:article3) { FactoryBot.create(:article, article_category: article_category1, price_te: 512.56) }
    let(:article4) { FactoryBot.create(:article, article_category: article_category2, price_te: 17.62) }

    before do
      Invoice::AddArticles.new(invoice, [article1.id, article2.id]).execute
      Invoice::AddArticles.new(invoice, [article3.id, article4.id]).execute

      invoice.reload
    end

    it 'creates a Hash categorizing order items prizes' do
      expect(subject.prices_te_by_articles_categories.keys).to eql [article_category1.name, article_category2.name]

      expect(subject.prices_te_by_articles_categories[article_category1.name]).to match('639,43')
      expect(subject.prices_te_by_articles_categories[article_category2.name]).to match('45,74')
    end
  end

  describe '#subscription_plan_order_item_price_te' do
    let(:subscription_plan) { FactoryBot.create(:subscription_plan, price_te: 45.87) }
    let(:subscription) { FactoryBot.create(:subscription, subscription_plan: subscription_plan) }

    context 'with an order with a SubscriptionPlan' do
      before {  Order::CreateFromSubscription.new(subject, subscription).execute }

      describe '#subscription_plan_order_item_price_te' do
        it { expect(subject.subscription_plan_order_item_price_te).to match '45,87' }
      end
    end

    context 'without an order with a SubscriptionPlan' do
      describe '#subscription_plan_order_item_price_te' do
        it { expect(subject.subscription_plan_order_item_price_te).to be_nil }
      end
    end
  end

  describe '#order_items' do
    context "without any order" do
      describe '#order_items' do
        it { expect(subject.order_items).to be_empty }
      end
    end

    context "with orders set" do
      let(:order1) { FactoryBot.create(:order, user: invoice.user) }
      let(:order2) { FactoryBot.create(:order, user: invoice.user) }

      before do
        article = FactoryBot.create(:article)
        subscription_plan = FactoryBot.create(:subscription_plan)

        Order::AddProduct.new(order1, article).execute
        Order::AddProduct.new(order2, subscription_plan).execute

        invoice.orders << order1
        invoice.orders << order2
      end

      it "should include all the order_items from the orders and decorate them" do
        expect(subject.order_items.length).to eql(2)
        expect(subject.order_items.map(&:id)).to eql([order1.order_items.last.id, order2.order_items.last.id])
        expect(subject.order_items.last).to be_a(OrderItemDecorator)
      end
    end
  end

  describe '#pdf_file_name' do
    describe '#pdf_file_name' do
      it { expect(subject.pdf_file_name).to match(subject.object.created_at.year.to_s) }
    end
  end

  describe '#order_item_product_name' do
    let(:invoice) do
      FactoryBot.create(:invoice,
        subscription_period_start_at: Date.new(2014, 5, 7),
        subscription_period_end_at: Date.new(2014, 8, 21))
    end

    let(:order_item) do
      FactoryBot.create(:order_item,
        product: product,
        product_name: product.name,
        product_price_ati: product.price_ati,
        product_price_te: product.price_te,
        product_taxes_rate: product.taxes_rate
      )
    end

    context 'with an Article' do
      let(:product) { FactoryBot.create(:article, name: 'The article name') }

      it 'returns the product name' do
        expect(subject.order_item_product_name(order_item)).to eql 'The article name'
      end
    end

    context 'with a SubscriptionPlan' do
      let(:product) { FactoryBot.create(:subscription_plan, name: 'Subscription name') }

      it 'returns the product name with dates' do
        expect(subject.order_item_product_name(order_item)).to eql 'Subscription name (du 07/05/2014 au 21/08/2014)'
      end
    end
  end

  describe '#paybox_transaction_number' do
    let(:invoice) { FactoryBot.create(:invoice, :with_accepted_invoice) }

    before do
      invoice.wait_for_payment!
      invoice.accept_payment!
    end

    describe '#paybox_transaction_number' do
      it { expect(subject.paybox_transaction_number).to match('Num Appel : 0011124512 | Ref Paybox : 0095214521') }
    end
  end
end
