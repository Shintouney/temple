require 'rails_helper'

describe CardScansController, type: :controller do
  let(:card_scan_attributes) do
    { accepted: false, scanned_at: "2014-03-06T18:48:19+01:00", scan_point: CardScan::SCAN_POINTS[:bar_entrance_moliere], card_reference: '123456789ABDEF12' }
  end
  let!(:user) { FactoryBot.create(:user, card_reference: '123456789ABDEF12') }

  before { request.headers['X-Auth'] = 'test' }

  describe '#create' do
    context 'with a valid requet' do
      it 'creates a CardScan record' do
        card_scans_count = CardScan.count

        xhr :post, :create, card_scan_attributes.to_json, format: :json

        expect(response.status).to eql 201

        expect(CardScan.count).to eql card_scans_count + 1

        card_scan = CardScan.last

        expect(card_scan.accepted).to be false
        expect(card_scan.scanned_at).to eql "2014-03-06T18:48:19+01:00".to_time
        expect(card_scan.scan_point_value).to eql CardScan::SCAN_POINTS[:bar_entrance_moliere]
        expect(card_scan.card_reference).to eql '123456789ABDEF12'

        json_response = JSON.parse(response.body)

        expect(json_response['accepted']).to eql false
        expect(json_response['card_reference']).to eql '123456789ABDEF12'
        expect(json_response['scanned_at']).to eql "2014-03-06T18:48:19.000+01:00"
        expect(json_response['scan_point']).to eql CardScan::SCAN_POINTS[:bar_entrance_moliere]
      end
    end

    context 'with an invalid request' do
      it 'returns a 400 Bad Request HTTP code' do
        xhr :post, :create, { scan_point: CardScan::SCAN_POINTS[:bar_entrance], card_reference: '123456789ABDEF12' }.to_json, format: :json

        expect(response.status).to eql 400

        json_response = JSON.parse(response.body)

        expect(json_response['errors'].keys.sort).to eql ['accepted', 'scan_point', 'scanned_at']
      end
    end

    context 'with unexistant card reference' do
      let!(:user) { FactoryBot.create(:user, card_reference: '123456789ABDEFFF') }

      it 'returns a 404 Not Found HTTP code' do
        xhr :post, :create, card_scan_attributes.to_json, format: :json

        expect(response.status).to eql 404
        expect(response.body).to be_blank
      end
    end

    context 'with an invalid format' do
      it 'returns a 406 Not Acceptable HTTP code' do
        expect { post :create, card_scan_attributes.to_json, format: :html }.to raise_error(ActionController::UnknownFormat)
      end
    end

    context 'with an invalid authentication token' do
      before { request.headers['X-Auth'] = 'foo_bat' }

      it 'returns a 401 Not Authorized HTTP code' do
        xhr :post, :create, card_scan_attributes.to_json, format: :json

        expect(response.status).to eql 401
        expect(response.body).to be_blank
      end
    end
  end
end
