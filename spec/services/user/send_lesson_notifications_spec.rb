require 'rails_helper'

describe User::SendLessonNotifications do

  let(:lesson) { FactoryBot.create(:lesson, max_spots: 1, start_at: Time.now + 3.hours) }
  let(:user) { FactoryBot.create(:user) }

  subject { User::SendLessonNotifications.new(lesson) }

  describe '#execute' do
    it 'does send notification mail' do
      Notification.create!(sourceable_id: lesson.id, sourceable_type: 'Lesson', user: user)
      emails_count = email_queue.size

      subject.execute

      expect(email_queue.size).to eql emails_count + 1
    end

    it 'does not send notification mail because no place available in Lesson' do
      lesson.update_attribute(:max_spots, 0)
      emails_count = email_queue.size

      subject.execute

      expect(email_queue.size).to eql emails_count
    end
  end
end
