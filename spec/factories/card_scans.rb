FactoryBot.define do
  factory :card_scan do
    user
    scanned_at { "2014-03-03 16:53:21" }
    scan_point { CardScan::SCAN_POINTS[:front_door_moliere] }
    accepted { true }
    card_reference { SecureRandom.hex(8).upcase }
  end
end
