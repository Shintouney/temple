# encoding: utf-8

require 'rails_helper'

describe AdminMailer do
  describe '#monthly_subscription_payment_retry_failed' do
    let!(:user) { FactoryBot.create(:user).decorate }
    subject { AdminMailer.monthly_subscription_payment_retry_failed(user.id) }

    describe '#to' do
      it { expect(subject.to).to eql Settings.mailer.admin.to }
    end

    describe '#encoded' do
      it { expect(subject.encoded).to include(user.full_name) }
    end
  end

  describe "#error" do
    subject { AdminMailer.error("ActiveMerchant::ConnectionError", ActiveMerchant::ConnectionError.new) }

    describe '#subject' do
      it { expect(subject.subject).to include('ERREUR')}
    end

    describe '#encoded' do
      it { expect(subject.encoded).to include('ActiveMerchant::ConnectionError')}
    end
  end

  describe "#invoice_charge_error" do
    subject { AdminMailer.invoice_charge_error([1]) }

    describe '#subject' do
      it { expect(subject.subject).to include('ERREUR')}
    end

    describe '#encoded' do
      it { expect(subject.encoded).to include('Une erreur est survenue')}
    end
  end

  describe '#sepa_payment_rejected' do
    let(:payment) { FactoryBot.create :payment, :with_credit_card, slimpay_direct_debit_id: '321654987', slimpay_status: 'declined' }
    subject { AdminMailer.sepa_payment_rejected(payment.id) }

    describe '#to' do
      it { expect(subject.to).to eql Settings.mailer.admin.to }
    end
    specify{ expect(subject.encoded).to include(payment.slimpay_direct_debit_id) }
  end

  describe '#suspicious_invoices' do
    let!(:user) { FactoryBot.create(:user).decorate }
    subject { AdminMailer.suspicious_invoices([user.id]) }

    describe '#to' do
      it { expect(subject.to).to eql ['developers@tsc.digital'] }
    end

    describe '#subject' do
      it { expect(subject.subject).to eq(I18n.t('admin_mailer.suspicious_invoices.subject')) }
    end
  end

  describe '#invalid_invoices' do
    let!(:invoice) { FactoryBot.create :invoice }
    subject { AdminMailer.invalid_invoices([invoice.id]) }

    describe '#to' do
      it { expect(subject.to).to eql ['developers@tsc.digital'] }
    end

    describe '#subject' do
      it { expect(subject.subject).to eq(I18n.t('admin_mailer.invalid_invoices.subject')) }
    end

    describe '#encoded' do
      it { expect(subject.encoded).to include(invoice.id.to_s) }
    end
  end

  describe '#invalid_users for payment_mode errors' do
    let!(:user) { FactoryBot.create :user, :with_registered_credit_card, payment_mode: 'none' }
    subject { AdminMailer.invalid_users({user.id => 'test sentence bad user payment mode'}, :payment_mode) }

    describe '#to' do
      it { expect(subject.to).to eql ['developers@tsc.digital'] }
    end

    describe '#subject' do
      it { expect(subject.subject).to eq(I18n.t('admin_mailer.payment_mode.subject')) }
    end

    describe '#encoded' do
      it { expect(subject.encoded).to include(user.id.to_s) }
    end
  end

  describe '#invalid_users for pending_subscription errors' do
    let!(:subscription) { FactoryBot.create :subscription}
    subject { AdminMailer.invalid_users({subscription.user_id => 'test sentence bad user payment mode'}, :pending_subscription) }

    describe '#to' do
      it { expect(subject.to).to eql ['developers@tsc.digital'] }
    end

    describe '#subject' do
      it { expect(subject.subject).to eq(I18n.t('admin_mailer.pending_subscription.subject')) }
    end

    describe '#encoded' do
      it { expect(subject.encoded).to include(subscription.user_id.to_s) }
    end
  end

  describe '#invoices_with_double_payments' do
    let!(:invoice) { FactoryBot.create :invoice }
    subject { AdminMailer.invoices_with_double_payments([invoice.id]) }

    describe '#to' do
      it { expect(subject.to).to eql ['developers@tsc.digital'] }
    end

    describe '#subject' do
      it { expect(subject.subject).to eq(I18n.t('admin_mailer.invoices_with_double_payments.subject')) }
    end

    describe '#encoded' do
      it { expect(subject.encoded).to include(invoice.id.to_s) }
    end
  end

  describe '#suspended_subscription' do
    let!(:user) { FactoryBot.create(:user, :with_running_subscription) }

    subject { AdminMailer.suspended_subscription(user) }

    describe '#to' do
      it { expect(subject.to).to eql ['developers@tsc.digital'] }
    end

    describe '#subject' do
      it { expect(subject.subject).to eq(I18n.t('admin_mailer.suspended_subscription.subject')) }
    end

    describe '#encoded' do
      it { expect(subject.encoded).to include(user.email) }
    end
  end

  describe '#restart_subscription_fail' do
    let!(:user) { FactoryBot.create(:user, :with_running_subscription) }

    subject { AdminMailer.restart_subscription_fail(user) }

    describe '#to' do
      it { expect(subject.to).to eql ['developers@tsc.digital'] }
    end

    describe '#subject' do
      it { expect(subject.subject).to eq(I18n.t('admin_mailer.restart_subscription_fail.subject')) }
    end

    describe '#encoded' do
      it { expect(subject.encoded).to include(user.email) }
    end
  end
end
