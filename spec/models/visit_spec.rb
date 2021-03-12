require 'rails_helper'

describe Visit do
  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:checkin_scan).class_name('CardScan') }
  it { is_expected.to belong_to(:checkout_scan).class_name('CardScan') }

  it { is_expected.to validate_presence_of(:started_at) }
  it { is_expected.to validate_presence_of(:user) }

  describe 'validates uniqueness of user' do
    let!(:user) { FactoryBot.create(:user) }

    context 'creating a finished visit' do
      subject { FactoryBot.build(:visit, user: user) }

      context 'for a user with finished visits' do
        before { FactoryBot.create_list(:visit, 10, user: user) }

        it 'creates a visit' do
          expect(subject.valid?).to be true
          expect(subject.save).to be true
        end
      end

      context 'for a user with a visit in progress' do
        before { FactoryBot.create(:visit, :in_progress, user: user) }

        it 'creates a visit' do
          expect(subject.valid?).to be true
          expect(subject.save).to be true
        end
      end
    end

    context 'creating visit in progress' do
      subject { FactoryBot.build(:visit, :in_progress, user: user) }

      context 'for a user with finished visits' do
        before { FactoryBot.create_list(:visit, 10, user: user) }

        it 'creates a visit' do
          expect(subject.valid?).to be true
          expect(subject.save).to be true
        end
      end

      context 'for a user with a visit in progress' do
        before { FactoryBot.create(:visit, :in_progress, user: user) }

        it 'does not create a visit' do
          expect(subject.valid?).to be false
          expect(subject.save).to be false
        end
      end
    end
  end

  describe 'ended_at validation' do
    context 'given a visit in progress' do
      subject { FactoryBot.create(:visit, :in_progress, started_at: Time.new(2014, 1, 2, 10, 30)) }

      context 'with an ended_at time after the started_at time' do
        before { subject.ended_at = (subject.started_at + 1.hour) }

        it { is_expected.to be_valid }
      end

      context 'with an ended_at time before the started_at time' do
        before { subject.ended_at = (subject.started_at - 1.hour) }

        it { is_expected.not_to be_valid }
      end
    end
  end

  describe '#in_progress?' do
    context 'with an unfinished visit' do
      subject { FactoryBot.build(:visit, :in_progress) }

      specify { expect(subject.in_progress?).to be true }
    end

    context 'with a finished visit' do
      subject { FactoryBot.build(:visit) }

      specify { expect(subject.in_progress?).to be false }
    end
  end

  describe '#finish!' do
    context 'with an unfinished visit' do
      subject { FactoryBot.build(:visit, :in_progress) }
      before { Timecop.freeze }
      after { Timecop.return }

      it 'finishes the visit' do
        expect(subject.finish!).to be true
        expect(subject.ended_at.utc).to be_within(1.second).of(Time.now.utc)
      end

      context "with a given card_scan" do
        let(:card_scan) do
          FactoryBot.create(:card_scan, user: subject.user, scanned_at: (subject.started_at + 1.hour))
        end

        it 'finishes the visit' do
          expect(subject.finish!(card_scan)).to be true
          expect(subject.ended_at.to_time).to eql(card_scan.scanned_at.to_time)
          expect(subject.checkout_scan).to eql(card_scan)
        end

        context "with a given ended_at" do
          let(:ended_at) { subject.started_at + 3.hours }

          it 'finishes the visit and sets the ened_at' do
            expect(subject.finish!(card_scan, ended_at)).to be true
            expect(subject.ended_at.to_time).to eql(ended_at.to_time)
            expect(subject.checkout_scan).to eql(card_scan)
          end
        end
      end

      context "with a given ended_at" do
        let(:ended_at) { subject.started_at + 3.hours }

        it 'finishes the visit and sets the ened_at' do
          expect(subject.finish!(nil, ended_at)).to be true
          expect(subject.ended_at.to_time).to eql(ended_at.to_time)
        end
      end
    end

    context 'with a finished visit' do
      subject { FactoryBot.build(:visit, ended_at: DateTime.now - 1.day) }

      it 'it does not finish the visit' do
        expect(subject.finish!).to be false
        expect(subject.ended_at).not_to eql DateTime.now
      end
    end
  end
end
