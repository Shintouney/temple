require 'rails_helper'

describe Notification do
  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:sourceable) }

  it { is_expected.to validate_presence_of(:sourceable_type) }
  it { is_expected.to validate_presence_of(:sourceable_id) }
  it { is_expected.to validate_presence_of(:user_id) }

  it 'Should not create 2 notifications on same lesson/user' do
    user = FactoryBot.create(:user)
    lesson = FactoryBot.create(:lesson)
    Notification.create!(user: user, sourceable_id: lesson.id, sourceable_type: 'Lesson')

    notification = Notification.new(user: user, sourceable_id: lesson.id, sourceable_type: 'Lesson')
    expect(notification).not_to be_valid
  end

  it 'Should create 2 notifications on same user for 2 models Lesson and Article' do
    user = FactoryBot.create(:user)
    lesson = FactoryBot.create(:lesson)
    Notification.create!(user: user, sourceable_id: lesson.id, sourceable_type: 'Lesson')

    notification = Notification.new(user: user, sourceable_id: lesson.id, sourceable_type: 'Article')
    expect(notification).to be_valid
  end
end
