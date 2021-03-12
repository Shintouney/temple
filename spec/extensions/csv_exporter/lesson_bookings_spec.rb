require 'rails_helper'

describe CSVExporter::LessonBookings do
  describe "génératate a csv" do
    let(:lesson_booking_export) { FactoryBot.create :export, :lesson_booking_export }
    let(:user) { FactoryBot.create :user, :with_running_subscription }
    let(:lesson_booking) { FactoryBot.create :lesson_booking, :past_lesson_booking, user: user }

    subject { CSVExporter::LessonBookings.new(lesson_booking_export) }

    context "without issue" do

      it "complete the export" do
        subject.execute
        expect(lesson_booking_export.state).to eq('completed')
      end
    end
  end
end
