require 'rails_helper'

describe Lessons::SendLessonEvent do
  let!(:user) { FactoryBot.create(:user) }
  let!(:lesson) { FactoryBot.create(:lesson) }
  subject { Lessons::SendLessonEvent.new(user, lesson, true) }

  describe '#execute' do
    it 'send a confirmation email with a .ics attach' do
      expect{ subject.execute }.to change{ email_queue.size }.by(1)
    end
  end
end
