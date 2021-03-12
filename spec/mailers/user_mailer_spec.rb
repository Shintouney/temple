require "spec_helper"

describe UserMailer do
  let(:user) { FactoryBot.create(:user) }

  describe '#welcome' do
    subject { UserMailer.welcome(user.id) }

    describe '#to' do
      it { expect(subject.to).to eq([user.email]) }
    end

    describe '#encoded' do
      it { expect(subject.encoded).to include(account_root_url) }
    end
  end

  describe '#subscription_suspended' do
    let!(:user) { FactoryBot.create(:user, :with_running_subscription) }

    subject { UserMailer.subscription_suspended(user.id, Date.today) }

    describe '#to' do
      it { expect(subject.to).to eql [user.email] }
    end

    describe '#subject' do
      it { expect(subject.subject).to eq(I18n.t('user_mailer.subscription_suspended.subject')) }
    end

    describe '#encoded' do
      it { expect(subject.encoded).to include(I18n.l(Date.today)) }
    end
  end

  describe '#subscription_restart' do
    let!(:user) { FactoryBot.create(:user, :with_running_subscription) }

    subject { UserMailer.subscription_restart(user.id) }

    describe '#to' do
      it { expect(subject.to).to eql [user.email] }
    end

    describe '#subject' do
      it { expect(subject.subject).to eq(I18n.t('user_mailer.subscription_restart.subject')) }
    end

    describe '#encoded' do
      it { expect(subject.encoded).to include(I18n.t('user_mailer.subscription_restart.wish_good_restart')) }
    end
  end

  describe '#reset_password_email' do
    before { user.update_attribute :reset_password_token, 'password_token' }
    subject { UserMailer.reset_password_email(user.id) }

    describe '#to' do
      it { expect(subject.to).to eq([user.email]) }
    end

    describe '#encoded' do
      it { expect(subject.encoded).to include(user.reset_password_token) }
    end
  end

  describe '#invite_friend' do
    let(:to) { 'friend1@example.com, friend2@example.com' }
    let(:text) { "A friendly message" }

    subject { UserMailer.invite_friend(user.id, to, text) }

    describe '#bcc' do
      it { expect(subject.bcc).to eql(['friend1@example.com', 'friend2@example.com']) }
    end

    describe '#reply_to' do
      it { expect(subject.reply_to).to eql([user.email]) }
    end

    describe '#encoded' do
      it { expect(subject.encoded).to include(text) }
    end
  end

  describe "#lesson_canceled" do
    let(:lesson_booking) { FactoryBot.create(:lesson_booking, user: user) }

    subject do
      UserMailer.lesson_canceled(user.id,
                                 lesson_booking.lesson.start_at,
                                 lesson_booking.lesson.end_at,
                                 lesson_booking.lesson.coach_name,
                                 lesson_booking.lesson.activity)
    end

    describe '#to' do
      it { expect(subject.to).to eq([user.email]) }
    end

    describe '#encoded' do
      it { expect(subject.encoded).to include(lesson_booking.lesson.activity) }
    end
  end

  describe "#send_lesson_notification" do
    let(:lesson) { FactoryBot.create(:lesson) }
    let(:lesson_booking) { FactoryBot.create(:lesson_booking, user: user, lesson: lesson) }
    let(:notification) { FactoryBot.create :notification, user: user, sourceable: lesson }

    subject { UserMailer.send_lesson_notification(lesson.id, user.id) }

    describe '#to' do
      it { expect(subject.to).to eq([user.email]) }
    end

    describe '#subject' do
      it { expect(subject.subject).to include I18n.l(lesson.start_at, format: "%d/%m") }
    end
  end

  describe "#lesson_booking_confirmation" do
    let(:lesson) { FactoryBot.create(:lesson) }

    subject { UserMailer.lesson_booking_confirmation(user.id, lesson.id) }

    describe '#to' do
      it { expect(subject.to).to eq([user.email]) }
    end

    describe '#subject' do
      it { expect(subject.subject).to include I18n.l(lesson.start_at, format: "%d/%m") }
    end
  end

  describe "#send_ical_invite" do
    let(:lesson) { FactoryBot.create(:lesson) }

    subject do
      f = File.open("tmp/42#{user.id}875843.ics", "w+")
      f.write("BEGIN:VCALENDAR")
      f.close
      UserMailer.send_ical_invite(user.id, lesson.id, "tmp/42#{user.id}875843.ics", true)
    end

    after do
      File.delete("tmp/42#{user.id}875843.ics")
    end

    describe '#to' do
      it { expect(subject.to).to eq([user.email]) }
    end

    describe '#encoded' do
      it { expect(subject.encoded).to include(user.email) }
    end

    describe '#encoded' do
      it { expect(subject.encoded).to include('BEGIN:VCALENDAR') }
    end

    describe '#content_type' do
      it { expect(subject.content_type).to include('multipart/alternative') }
    end
  end

  describe "#send_ical_invite with a bad ics" do
    let(:lesson) { FactoryBot.create(:lesson) }

    subject do
      UserMailer.send_ical_invite(user.id, lesson.id, "tmp/bogus.ics", true)
    end

    describe '#to' do
      it { expect(subject.to).to eq([user.email]) }
    end

    describe '#encoded' do
      it { expect(subject.encoded).to include(user.email) }
    end

    describe '#encoded' do
      it { expect(subject.encoded).not_to include('BEGIN:VCALENDAR') }
    end
  end
end
