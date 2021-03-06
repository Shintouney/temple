require 'rails_helper'

describe ArticleCategory do
  it { is_expected.to have_many(:articles) }

  it { is_expected.to validate_presence_of(:name) }
end
