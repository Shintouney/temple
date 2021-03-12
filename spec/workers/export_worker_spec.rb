require 'rails_helper'

describe ExportWorker do
  describe 'perform' do
    let(:user) {FactoryBot.create :user, :with_running_subscription}
    let(:export) { FactoryBot.create :export }
    let(:lesson_booking_export) { FactoryBot.create :export, :lesson_booking_export }
    let(:payment_export) { FactoryBot.create :export, :payment_export }

    let(:lesson_booking) { FactoryBot.create :lesson_booking, :past_lesson_booking, user: user }

    let(:article) { FactoryBot.create :article, price_ati: 263.75, price_te: 250.0, taxes_rate: 5.5 }
    let(:invoice) { FactoryBot.create :invoice, created_at: Time.zone.now.advance(days: -2) }
    let(:payment) { FactoryBot.create :payment, :with_accepted_credit_card }
    let(:order) { FactoryBot.build(:order, invoice: invoice) }

    before do
      Order::AddProduct.new(order, article).execute
      order.save!

      invoice.wait_for_payment!
      invoice.accept_payment!
      payment.invoices << invoice
    end

    it 'launches an exporter with the export id' do
      exporter = CSVExporter::Invoices.new(export)
      CSVExporter::Invoices.should_receive(:new) { exporter }
      subject.perform(export.id)
      expect(export.state).to eq('completed')
    end

    it 'launches an lesson bookings exporter with the export id' do
      lesson_booking
      exporter = CSVExporter::LessonBookings.new(lesson_booking_export)
      CSVExporter::LessonBookings.should_receive(:new) { exporter }
      subject.perform(lesson_booking_export.id)
      expect(lesson_booking_export.state).to eq('completed')
    end

    it 'launches an payments exporter with the export id' do
      exporter = CSVExporter::Payments.new(payment_export)
      CSVExporter::Payments.should_receive(:new) { exporter }
      subject.perform(payment_export.id)
      expect(payment_export.state).to eq('completed')
    end

    context 'when something goes wrong' do
      it 'raise an issue' do
        exporter = CSVExporter::Invoices.new(export)
        export.should_receive(:destroy)
        Raven.should_receive(:capture_exception)
        allow(export).to receive(:invoices).and_raise(StandardError.new(:test))
        exporter.execute
      end

      it 'raise an issue on Payments' do
        exporter = CSVExporter::Payments.new(payment_export)
        payment_export.should_receive(:destroy)
        Raven.should_receive(:capture_exception)
        allow(payment_export).to receive(:payments).and_raise(StandardError.new(:test))
        exporter.execute
      end

      it 'raise an issue on LessonBookings' do
        exporter = CSVExporter::LessonBookings.new(lesson_booking_export)
        lesson_booking_export.should_receive(:destroy)
        Raven.should_receive(:capture_exception)
        allow(lesson_booking_export).to receive(:lesson_bookings).and_raise(StandardError.new(:test))
        exporter.execute
      end
    end
  end
end
