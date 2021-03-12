require 'rails_helper'

RSpec.shared_examples "a model with lessons attributes" do
  it { should validate_presence_of(:coach_name) }
  it { should validate_presence_of(:activity) }

  it { should validate_presence_of(:room) }
  it { should enumerize(:room).in(:ring, :training, :arsenal, :ring_no_opposition, :ring_no_opposition_advanced, :ring_feet_and_fist) }

  it { should allow_value(1, 4, 0, nil).for(:max_spots) }
  it { should_not allow_value(-1).for(:max_spots) }
  it { should_not allow_value(1.25).for(:max_spots) }
end
