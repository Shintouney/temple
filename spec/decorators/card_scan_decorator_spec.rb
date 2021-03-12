require 'rails_helper'

describe CardScanDecorator do
  let!(:card_scan) do
    FactoryBot.create(:card_scan,
                       accepted: false,
                       scan_point: CardScan::SCAN_POINTS[:bar_entrance_moliere],
                       scanned_at: '2014-03-06T18:48:19+01:00',
                       card_reference: '123456789ABDEF12')
  end
  subject { CardScanDecorator.decorate(card_scan) }

  describe '#scanned_at_human_time' do
    let(:current_time) { Time.new(2014, 5, 2, 14, 30, 0) }
    before { Timecop.freeze(current_time) }
    after { Timecop.return }

    context "for a scanned_at in the present day" do
      before { card_scan.update_attributes! scanned_at: current_time - 1.hour }

      it "should only include the time" do
        expect(subject.scanned_at_human_time).not_to match('02/05')
      end
    end

    context "for a scanned_at in a previous day" do
      before { card_scan.update_attributes! scanned_at: current_time - 1.day }

      it "should include the time and day" do
        expect(subject.scanned_at_human_time).to match('01/05')
      end
    end
  end

  describe '#to_api_json' do
    it 'returns a JSON payload with recorded attributes' do
      expect(subject.to_api_json).to eql(
        'accepted' => false,
        'scan_point' => CardScan::SCAN_POINTS[:bar_entrance_moliere],
        'scanned_at' => Time.new(2014, 3, 6, 18, 48, 19, '+01:00'),
        'card_reference' => '123456789ABDEF12'
      )
    end
  end

  describe '#error_messages_as_json' do
    before do
      subject.scan_point = nil
      subject.save
    end

    it 'returns a JSON payload with errors' do
      expect(subject.error_messages_as_json).to eql(
        errors: { scan_point: ['doit être renseigné '] }
      )
    end
  end
end
