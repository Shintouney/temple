require 'rails_helper'

describe UserImage do
  it { is_expected.to belong_to(:user) }
  it { is_expected.to validate_presence_of(:user) }

  it { is_expected.to have_one(:user_as_profile_user_image) }

  it { is_expected.to have_attached_file(:image) }
  it { is_expected.to validate_attachment_presence(:image) }
  it { is_expected.to validate_attachment_content_type(:image).allowing('image/jpeg', 'image/png').rejecting('text/plain', 'text/xml') }
  it { is_expected.to validate_attachment_size(:image).less_than(4.megabytes) }
end
