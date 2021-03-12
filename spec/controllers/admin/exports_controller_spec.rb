require 'rails_helper'

describe Admin::ExportsController, type: :controller do
  before { login_user(FactoryBot.create(:admin)) }

  let!(:export) { FactoryBot.create :export }

  describe 'progress' do
    let!(:invoices) { FactoryBot.create_list :invoice, 3, created_at: Time.zone.now.advance(days: -1) }

    before do
      invoices.first.wait_for_payment!
      invoices.first.accept_payment!
    end

    it 'renders progress integer percentage' do
      ProgressTracker.any_instance.should_receive(:progress_percentage) { 42 }
      get :progress, id: export.id
      expect(response.body).to eq('42')
    end
  end

  describe 'refresh_link' do
    before do
      export.state = 'completed'
      export.save!
    end

    it 'returns the export show url' do
      get :refresh_link, export: { type: 'invoice', subtype: 'finished' }
      expect(response.body).to eq({ success: true, url: admin_export_path(export), name: export.filename }.to_json)
    end
  end
end
