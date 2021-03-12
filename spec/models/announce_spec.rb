require 'rails_helper'

describe Announce do
  it { is_expected.not_to allow_value("plop").for(:target_link) }
  it { is_expected.to allow_value("google.com").for(:target_link) }
  it { is_expected.to have_attached_file(:file) }
  it { is_expected.to validate_attachment_content_type(:file).allowing('image/png', 'image/jpeg') }
  it { is_expected.to validate_attachment_content_type(:file).rejecting('text/plain', 'text/xml') }
  it { is_expected.to validate_attachment_size(:file).less_than(4.megabytes) }
  it { is_expected.to enumerize(:place).in(:all, :dashboard) }

  describe "#counter_activate" do
    let!(:announce_1) { FactoryBot.create :announce, active: false }
    let!(:announce_2) { FactoryBot.create :announce }
    let!(:announce_3) { FactoryBot.create :announce, place: 'dashboard' }

    it "desactivate other announces" do
      announce_1.update_attribute :active, true
      expect(announce_1.reload.active).to be true
      expect(announce_2.reload.active).to be false
      expect(announce_3.reload.active).to be false
    end
  end
end
