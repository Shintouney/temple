require 'acceptance/acceptance_helper'

feature "User lesson booking", type: :feature do
  let!(:user) { FactoryBot.build(:user, :with_registered_credit_card, force_access_to_planning: true) }

  before do
    login_with(user)
    FactoryBot.create(:subscription, user: user, state: 'running')
    Timecop.travel(Date.today.to_time + 8.hours)
  end

  after { Timecop.return }

  context "logged in as a user" do
    let!(:lesson) { FactoryBot.create(:lesson, start_at: (Time.now + 4.hours)) }

    context 'Booking a lesson ' do
      let!(:lesson_already_book) { FactoryBot.create(:lesson, start_at: (Time.now + 12.hours)) }
      let!(:notif) { FactoryBot.create :notification, sourceable_id: lesson.id, sourceable_type: 'Lesson', user: user }
      let!(:lesson_booking_count) { LessonBooking.count }
      let!(:mailer_queue) { email_queue.size }
      let!(:notification_count) { Notification.count }
      let!(:notification_schedule_count) { NotificationSchedule.count }

      scenario 'with a ical invit', js: true do
        visit account_root_path(location: 'moliere')

        FactoryBot.create :lesson_booking, user: user, lesson: lesson_already_book

        page.find("#lesson_#{lesson.id}").click
        wait_for_ajax

        expect(page).to have_text(lesson.coach_name)

        page.find("#lesson_booking_submit").click
        wait_for_ajax

        page.find(".popover.confirmation a[data-apply=confirmation]").click
        wait_for_ajax

        expect(page).not_to have_text(lesson.coach_name)
        expect(LessonBooking.count).to eql(lesson_booking_count + 1)
        expect(NotificationSchedule.count).to eql(notification_schedule_count + 1)
        expect(Notification.count).to eql(notification_count - 1)
        expect(email_queue.size).to eql(mailer_queue + 1)
      end

      scenario 'when the user already have a lesson booking', js: true do
        visit account_root_path(location: 'moliere')

        page.find("#lesson_#{lesson.id}").click
        wait_for_ajax

        expect(page).to have_text(lesson.coach_name)

        page.find("#lesson_booking_submit").click
        wait_for_ajax

        expect(page).not_to have_text(lesson.coach_name)
        expect(LessonBooking.count).to eql(lesson_booking_count + 1)
        expect(NotificationSchedule.count).to eql(notification_schedule_count + 1)
        expect(Notification.count).to eql(notification_count - 1)
        expect(email_queue.size).to eql(mailer_queue + 1)
      end

      scenario 'Booking a lesson without a ical invit', js: true do
        visit account_root_path(location: 'moliere')

        page.find("#lesson_#{lesson.id}").click
        wait_for_ajax

        expect(page).to have_text(lesson.coach_name)

        page.find("#send_lesson_event").click
        page.find("#lesson_booking_submit").click
        wait_for_ajax

        expect(page).not_to have_text(lesson.coach_name)
        expect(LessonBooking.count).to eql(lesson_booking_count + 1)
        expect(NotificationSchedule.count).to eql(notification_schedule_count + 1)
        expect(Notification.count).to eql(notification_count - 1)
        expect(email_queue.size).to eql(mailer_queue)
      end

      scenario 'Booking a lesson without email confirmation', js: true do
        visit account_root_path(location: 'moliere')

        page.find("#lesson_#{lesson.id}").click
        wait_for_ajax

        expect(page).to have_text(lesson.coach_name)

        page.find("#lesson_booking_mail_confirmation").click
        page.find("#lesson_booking_submit").click
        wait_for_ajax

        expect(page).not_to have_text(lesson.coach_name)
        expect(LessonBooking.count).to eql(lesson_booking_count + 1)
        expect(NotificationSchedule.count).to eql(notification_schedule_count)
        expect(Notification.count).to eql(notification_count - 1)
      end
    end

    context 'no available places' do
      before do
        lesson.max_spots = 0
        lesson.save!
      end
      let!(:notification_count) { Notification.count }

      scenario 'Request a notification on Lesson and then cancel the request', js: true do
        visit account_root_path(location: 'moliere')

        page.find("#lesson_#{lesson.id}").click
        wait_for_ajax

        expect(page).to have_text(lesson.coach_name)

        page.find('#notification_submit').click
        wait_for_ajax

        expect(page).not_to have_text(lesson.coach_name)

        expect(Notification.count).to eql(notification_count + 1)

        page.find("#lesson_#{lesson.id}").click
        wait_for_ajax

       expect(page).to have_text(lesson.coach_name)

        page.find('#destroy_notification_submit').click
        wait_for_ajax

        expect(page).not_to have_text(lesson.coach_name)

        expect(Notification.count).to eql(notification_count)
      end
    end

    scenario 'Viewing an unbookable lesson', js: true do
      lesson.update_attributes!(start_at: (Time.now - 2.hours))

      visit account_root_path(location: 'moliere')

      page.find("#lesson_#{lesson.id}").click
      wait_for_ajax

      expect(page).to have_css('.label-warning')
    end

    context 'when lesson already booked' do
      scenario 'Failing to book a lesson', js: true do
        lesson.update_attributes!(start_at: Time.now + 3.hours, max_spots: 1)

        visit account_root_path(location: 'moliere')

        page.find("#lesson_#{lesson.id}").click
        wait_for_ajax
        expect(page).to have_text(lesson.coach_name)

        LessonBooking.create!(lesson: lesson, user: FactoryBot.create(:user))

        page.find('#lesson_booking_submit').click
        wait_for_ajax

        expect(page).to have_css('.label-warning')
      end
    end

    scenario 'Viewing a lesson booked in the past', js: true do
      LessonBooking.create!(lesson: lesson, user: user)
      lesson.update_attributes!(start_at: (Time.now - 2.hours))

      visit account_root_path(location: 'moliere')

      page.find("#lesson_#{lesson.id}").click
      wait_for_ajax

      expect(page).to have_css('.label-warning')
      expect(page).not_to have_css('#lesson_booking_destroy_submit')
    end

    scenario 'Cancelling a lesson booking', js: true do
      lesson.update_attributes!(max_spots: 1)
      LessonBooking.create!(lesson: lesson, user: user)
      lesson_booking_count = LessonBooking.count
      Notification.create!(sourceable_id: lesson.id, sourceable_type: 'Lesson', user: FactoryBot.create(:user))

      mailer_queue = email_queue.size

      visit account_root_path(location: 'moliere')

      page.find("#next_lesson_booking_panel").click
      wait_for_ajax

      expect(page).to have_css('.label-success')

      assert_equal mailer_queue, email_queue.size

      page.execute_script "$('#lesson_booking_destroy_submit').trigger('click')"
      wait_for_ajax

      expect(page).not_to have_css('.label-success')

      expect(LessonBooking.count).to eql(lesson_booking_count - 1)

      assert_equal mailer_queue + 1, email_queue.size
    end

    context 'when a booking for another lesson already exists', js: true do
      let!(:other_lesson) { FactoryBot.create(:lesson, start_at: Time.now.advance(hours: 5), max_spots: 1) }

      before do
        lesson.update_attributes!(start_at: Time.now.advance(hours: 1), max_spots: 1)
        FactoryBot.create(:lesson_booking, lesson: lesson, user: user)
      end

      scenario "Booking a lesson fails" do
        expect(user.lessons.last).to eq(lesson)

        visit account_lessons_path(location: 'moliere')
        page.find(:css, "#lesson_#{other_lesson.id}").click
        wait_for_ajax
        expect(page).to have_text(other_lesson.coach_name)
        page.find(:css, "#lesson_booking_submit").click
        wait_for_ajax

        popover_id = page.find(:css, "#lesson_booking_submit")['aria-describedby']
        expect(page).to have_css("##{popover_id}")
        within("##{popover_id}") do
          expect(page).to have_css("a[data-apply='confirmation']")
          page.find(:css, "a[data-apply='confirmation']").click
          wait_for_ajax
        end

        expect(current_path).to eq(account_lessons_path)
        expect(LessonBooking.count).to eql 1
        # expect(user.lessons.last).to eq(other_lesson)
      end
    end
  end
end
