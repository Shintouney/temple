require 'rails_helper'

describe Invoice::Deferred::Create do
  let(:user) { FactoryBot.create(:user, current_subscription: subscription, current_deferred_invoice: current_deferred_invoice) }
  let(:subscription) { FactoryBot.create(:subscription, state: 'running') }
  let(:current_deferred_invoice) { nil }

  subject { Invoice::Deferred::Create.new(user) }

  describe '#new' do
    context 'when user has a no invoice for the current period' do
      describe '#user' do
        it { expect(subject.user).to eql user }
      end

      describe '#subscription' do
        it { expect(subject.subscription).to eql subscription }
      end
    end

    context 'when user has an invoice for the current period' do
      let(:current_deferred_invoice) { FactoryBot.create(:invoice) }

      it 'should raise an error' do
        expect { Invoice::Deferred::Create.new(user) }.to(raise_error(ArgumentError))
      end
    end

    context 'when user has no subscription' do
      let(:subscription) { nil }

      it 'should raise an error' do
        expect { Invoice::Deferred::Create.new(user) }.to(raise_error(ArgumentError))
      end
    end

    context 'when the user current subscription is not running' do
      let(:subscription) { FactoryBot.create(:subscription, state: 'canceled') }

      it 'should raise an error' do
        expect { Invoice::Deferred::Create.new(user) }.to(raise_error(ArgumentError))
      end
    end
  end

  describe '#execute' do
    let(:subscription) { FactoryBot.create(:subscription, start_at: '2012-02-18', state: 'running') }

    before { Timecop.freeze(2012, 04, 18, 14, 00, 00) }
    after { Timecop.return }

    it 'creates an Invoice for the current period and assigns it to the user' do
      expect { subject.execute }.to change { Invoice.count }.by(1)

      user.reload

      expect(user.current_deferred_invoice.start_at).to eql Date.new(2012, 04, 18)
      expect(user.current_deferred_invoice.end_at).to eql Date.new(2012, 05, 17)
      expect(user.current_deferred_invoice.subscription_period_start_at).to eql Date.new(2012, 05, 18)
      expect(user.current_deferred_invoice.subscription_period_end_at).to eql Date.new(2012, 06, 17)
      expect(user.current_deferred_invoice.next_payment_at).to eql Date.new(2012, 05, 18)

      expect(user.current_deferred_invoice.user_firstname).to eql user.firstname
      expect(user.current_deferred_invoice.user_lastname).to eql user.lastname
      expect(user.current_deferred_invoice.user_street1).to eql user.street1
      expect(user.current_deferred_invoice.user_street2).to eql user.street2
      expect(user.current_deferred_invoice.user_postal_code).to eql user.postal_code
      expect(user.current_deferred_invoice.user_city).to eql user.city

      expect(user.current_deferred_invoice).to be_open
    end

    context 'when user save fails' do
      before do
        Invoice.any_instance.should_receive(:save!).with(no_args).and_return(false)
      end

      it 'does not create an invoice' do
        expect { subject.execute }.not_to change { Invoice.count }
      end

      it 'does not change the user current deferred invoice' do
        expect { subject.execute }.not_to change { user.current_deferred_invoice }
      end
    end
  end

  describe '#create_invoice' do
    let(:user) { FactoryBot.create(:user, current_subscription: subscription, current_deferred_invoice: current_deferred_invoice) }
    after { Timecop.return }

    context 'created a 31th of January' do
      let(:subscription) do
        FactoryBot.create(:subscription, state: 'running', start_at: Date.new(2010, 1, 31),
                            next_payment_at: (Date.new(2010, 1, 31) + 1.month))
      end
      before { Timecop.travel(2010, 2, 28, 14, 00, 00) }
      it 'has a subscription next invoice on 28 Feb' do
        expect(subscription.next_payment_at).to eql(Date.new(2010, 2, 28))
      end
      it 'DOES NOT creates next invoice on 28 March' do
        subject.send(:create_invoice)
        expect(Invoice.last.next_payment_at).not_to eql(Date.new(2010, 3, 28))
      end
      it 'creates next invoice on 31 March' do
        subject.send(:create_invoice)
        expect(Invoice.last.next_payment_at).to eql(Date.new(2010, 3, 31))
      end
      context 'The month after that' do
        before { Timecop.travel(2010, 3, 31, 14, 00, 00) }
        it 'create n+2 invoice on 30 April' do
          subject.send(:create_invoice)
          expect(Invoice.last.next_payment_at).to eql(Date.new(2010, 4, 30))
        end
        context 'Two month after that' do
          before { Timecop.travel(2010, 4, 30, 14, 00, 00) }
          it 'create n+3 invoice on 31 Mai' do
            subject.send(:create_invoice)
            expect(Invoice.last.next_payment_at).to eql(Date.new(2010, 5, 31))
          end
        end
      end
    end
    context 'created a 31 August' do
      let(:subscription) do
        FactoryBot.create(:subscription, state: 'running', start_at: Date.new(2010, 8, 31),
                            next_payment_at: (Date.new(2010, 8, 31) + 1.month))
      end
      before { Timecop.travel(2010, 8, 31, 14, 00, 00) }
      it 'has a subscription next invoice on 30 September' do
        expect(subscription.current_period_start_date).to eql(Date.new(2010, 8, 31))
        expect(subscription.current_period_end_date).to eql(Date.new(2010, 9, 29))
        expect(subscription.next_payment_at).to eql(Date.new(2010, 9, 30))
      end
      it 'creates next invoice on 31 October' do
        Timecop.travel(2010, 9, 30, 14, 00, 00)
        subject.send(:create_invoice)
        expect(Invoice.last.next_payment_at).to eql(Date.new(2010, 10, 31))
      end
    end
    context 'created a 30 December before bisextille year' do
      let(:subscription) do
        FactoryBot.create(:subscription, state: 'running', start_at: Date.new(2011, 12, 30),
                            next_payment_at: (Date.new(2011, 12, 30) + 1.month))
      end
      before { Timecop.travel(2012, 1, 30, 14, 00, 00) }
      it 'has a subscription next invoice on 30 Jan' do
        expect(subscription.next_payment_at).to eql(Date.new(2012, 1, 30))
      end
      it 'creates next invoice on 29 Feb' do
        subject.send(:create_invoice)
        expect(Invoice.last.next_payment_at).to eql(Date.new(2012, 2, 29))
      end
      context 'The month after that' do
        before { Timecop.travel(2012, 2, 29, 14, 00, 00) }
        it 'creates next invoice on 30 March' do
          subject.send(:create_invoice)
          expect(Invoice.last.next_payment_at).to eql(Date.new(2012, 3, 30))
        end
        context 'Two month after that' do
          before { Timecop.travel(2012, 3, 30, 14, 00, 00) }
          it 'create n+3 invoice on 30 April' do
            subject.send(:create_invoice)
            expect(Invoice.last.next_payment_at).to eql(Date.new(2012, 4, 30))
          end
        end
      end
    end
  end
end
