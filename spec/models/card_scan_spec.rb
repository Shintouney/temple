require 'rails_helper'

describe CardScan do
  it { is_expected.to belong_to(:user) }

  it { is_expected.to have_one(:visit_as_checkin_scan).class_name('Visit') }
  it { is_expected.to have_one(:visit_as_checkout_scan).class_name('Visit') }

  it { is_expected.to validate_presence_of :card_reference }
  it { is_expected.to validate_presence_of :scanned_at }
  it { is_expected.to validate_presence_of :scan_point }
  it { is_expected.to validate_presence_of :user }

  it { is_expected.to allow_value(true).for(:accepted) }
  it { is_expected.to allow_value(false).for(:accepted) }
  it { is_expected.not_to allow_value(nil).for(:accepted) }

  describe "card_reference validations" do
    it { is_expected.to allow_value(SecureRandom.hex(8).upcase).for(:card_reference) }
    it { is_expected.not_to allow_value('ABCD').for(:card_reference) }
    it { is_expected.not_to allow_value('123456789 123456').for(:card_reference) }
  end

  describe "scan_point" do
    it { is_expected.to enumerize(:scan_point).in(:building_door_moliere, :front_door_moliere, :bar_entrance_moliere, :bar_exit_moliere,
                                          :building_door_maillot, :front_door_maillot, :bar_entrance_maillot, :bar_exit_maillot,
                                          :building_door_amelot, :front_door_amelot, :bar_entrance_amelot, :bar_exit_amelot) }
  end

  describe "build location" do
    it "should define location to maillot" do
      card_scan = FactoryBot.create :card_scan, scan_point: :building_door_maillot

      expect(card_scan.location).to eql('maillot')
    end
    it "should define location to moliere" do
      card_scan = FactoryBot.create :card_scan, scan_point: :building_door_moliere

      expect(card_scan.location).to eql('moliere')
    end
    it "should define location to amelot" do
      card_scan = FactoryBot.create :card_scan, scan_point: :building_door_amelot

      expect(card_scan.location).to eql('amelot')
    end
  end
end
