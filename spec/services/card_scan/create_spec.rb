require 'rails_helper'

describe CardScan::Create do
  let!(:user) { FactoryBot.create(:user) }
  let(:card_scan_params) do
    { accepted: true,
      scanned_at: '2014-03-03T18:48:19+01:00',
      scan_point: CardScan::SCAN_POINTS[:bar_entrance_moliere],
      card_reference: SecureRandom.hex(8).upcase }
  end

  subject { CardScan::Create.new(user, card_scan_params) }

  describe '#user' do
    describe '#user' do
      it { expect(subject.user).to eql user }
    end
  end

  describe '#execute' do
    context 'when card_scan params are invalid' do
      before do
        card_scan_params[:scanned_at] = "invalid"
      end

      it { expect(subject.execute).to be false }

      it "does not create a card_scan record" do
        expect{ subject.execute }.not_to change{ CardScan.count }
      end
    end

    context 'when card_scan params are valid' do
      it { expect(subject.execute).to be true }

      it "creates a card_scan record" do
        expect{ subject.execute }.to change{ CardScan.count }.by(1)
      end

      context "with a scan_point param matching the entry point" do
        context "when no visit is currently in progress for the user" do
          let!(:previous_visit) { FactoryBot.create(:visit, user: user) }

          it "creates a visit record" do
            expect{ subject.execute }.to change{ Visit.count }.by(1)

            visit = Visit.order(:created_at).last
            expect(visit.checkin_scan).to eql(subject.card_scan)
            expect(visit.user).to eql(user)
            expect(visit.started_at).to eql(subject.card_scan.scanned_at)
            expect(visit.ended_at).to be_nil
          end

          context "when the card_scan is not accepted" do
            before do
              card_scan_params[:accepted] = false
            end

            it "does not create a visit record" do
              expect{ subject.execute }.not_to change{ Visit.count }
            end
          end

          context 'when user is an admin' do
            before { user.role = 'admin' }

            it "does not create a visit record" do
              expect{ subject.execute }.not_to change{ Visit.count }
            end
          end
        end

        context "when a visit is currently in progress for the user" do
          let!(:previous_visit) { FactoryBot.create(:visit, :in_progress, user: user) }

          it "does not create a visit record" do
            expect{ subject.execute }.not_to change{ Visit.count }
          end

          it "does not update the currently in progress visit" do
            subject.execute

            previous_visit.reload

            expect(previous_visit.checkout_scan).to be_nil
            expect(previous_visit.ended_at).to be_nil
          end
        end
      end

      context "with a scan_point param matching the exit point" do
        before { card_scan_params[:scan_point] = CardScan::SCAN_POINTS[:bar_exit_moliere] }

        context "when no visit is currently in progress for the user" do
          let!(:previous_visit) { FactoryBot.create(:visit, user: user) }

          it "does not create a visit record" do
            expect{ subject.execute }.not_to change{ Visit.count }
          end
        end

        context "when a visit is currently in progress for the user" do
          let!(:previous_visit) { FactoryBot.create(:visit, :in_progress, user: user) }

          context "when the visit started_at time is before the card_scan scanned_at time" do
            before do
              previous_visit.update_attribute :started_at, Time.new(2014, 1, 2, 10, 30)
              card_scan_params[:scanned_at] = Time.new(2014, 1, 2, 11, 30)
            end

            it "does not create a visit record" do
              expect{ subject.execute }.not_to change{ Visit.count }
            end

            it "updates the currently in progress visit" do
              subject.execute

              previous_visit.reload

              expect(previous_visit.checkout_scan).to eql(subject.card_scan)
              expect(previous_visit.ended_at).to eql(subject.card_scan.scanned_at)
            end
          end

          context "when the visit started_at time is after the card_scan scanned_at time" do
            before do
              previous_visit.update_attribute :started_at, Time.now + 1.day
              card_scan_params[:scanned_at] = Time.now - 1.day
            end

            it "does not update the currently in progress visit" do
              subject.execute

              previous_visit.reload

              expect(previous_visit.checkout_scan).to be_nil
              expect(previous_visit.ended_at).to be_nil
            end
          end
        end
      end
    end
  end
end
