require 'rails_helper'

describe Article do
  it_behaves_like "a product model"

  it { is_expected.to belong_to(:article_category) }

  it { is_expected.to have_attached_file(:image) }
  it { is_expected.to validate_attachment_presence(:image) }
  it { is_expected.to validate_attachment_content_type(:image).allowing('image/jpeg', 'image/png').rejecting('text/plain', 'text/xml') }
  it { is_expected.to validate_attachment_size(:image).less_than(4.megabytes) }
end
