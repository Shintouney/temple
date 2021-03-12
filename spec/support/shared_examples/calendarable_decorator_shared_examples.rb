require 'rails_helper'

RSpec.shared_examples "a calendarable decorator" do
  describe '#description' do
    its(:description) { should match(subject.activity) }
    its(:description) { should match(subject.coach_name) }
  end

  describe '#room_calendar_class_name' do
    before { subject.room = 'ring' }

    its(:room_calendar_class_name) { should match('boxing-ring') }
  end

  describe '#formatted_title' do
    its(:formatted_title) { should match(subject.activity) }
  end
end
