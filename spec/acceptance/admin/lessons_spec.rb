require 'acceptance/acceptance_helper'

feature 'Admin lessons management', type: :feature do
  context "logged in as an admin" do
    before do
      login_as(:admin)

      Timecop.travel(Date.today.beginning_of_day + 8.hours)
    end

    after { Timecop.return }

    let!(:lesson) do
      FactoryBot.create(:lesson,
                         activity: "MMA",
                         start_at: (Time.now.beginning_of_day + rand(9..10).hours))
    end

    scenario 'Accessing the index', js: true do
      visit admin_lessons_path(location: 'moliere')

      expect(page).to have_text(lesson.activity)
    end

    scenario "Trying to create a lesson", js: true do
      lesson_count = Lesson.count

      visit admin_lessons_path(location: 'moliere')
      click_link "new_lesson"

      expect(page).to have_css('#lessonModal form')
      page.execute_script "$('#lesson_submit').trigger('click')"

      expect(page).to have_css('#lessonModal .has-error')

      expect(Lesson.count).to eql(lesson_count)
    end

    scenario "Creating a lesson", js: true do
      lesson_count = Lesson.count
      lesson_build = FactoryBot.build(:lesson,
                                       activity: "Foobaring",
                                       start_at: (Time.now.beginning_of_day + rand(14..16).hours))

      visit admin_lessons_path(location: 'moliere')
      click_link "new_lesson"

      select lesson_build.room.text, from: 'lesson_room'
      fill_in 'lesson_coach_name', with: lesson_build.coach_name
      fill_in 'lesson_activity', with: lesson_build.activity

      page.execute_script "$('#lesson_start_at_time_timepicker').removeAttr('readonly')"
      page.execute_script "$('#lesson_end_at_time_timepicker').removeAttr('readonly')"

      page.execute_script "$('#lesson_start_at_date_datepicker').val('#{I18n.l(lesson_build.start_at, format: '%d/%m/%Y')}').trigger('input')"
      page.execute_script "$('#lesson_start_at_time_timepicker').val('#{I18n.l(lesson_build.start_at, format: '%H:%M')}').trigger('input')"
      page.execute_script "$('#lesson_end_at_time_timepicker').val('#{I18n.l(lesson_build.end_at, format: '%H:%M')}').trigger('input')"

      wait_for_ajax

      page.execute_script "$('#lesson_submit').trigger('click')"

      expect(page).to have_text(lesson.activity)
      expect(page).to have_text(lesson_build.activity)

      expect(Lesson.count).to eql(lesson_count + 1)
    end

    scenario "Failing to edit a lesson", js: true do
      visit admin_lessons_path(location: 'moliere')

      page.find("#lesson_#{lesson.id}").click
      wait_for_ajax

      fill_in 'lesson_activity', with: ''

      page.execute_script "$('#lesson_submit').trigger('click')"
      wait_for_ajax

      expect(page).to have_css('#lessonModal .has-error')
    end

    scenario "Editing a lesson", js: true do
      new_activity = "Mixed Martial Arts"

      visit admin_lessons_path(location: 'moliere')

      page.find("#lesson_#{lesson.id}").click
      wait_for_ajax

      fill_in 'lesson_activity', with: new_activity

      page.execute_script "$('#lesson_submit').trigger('click')"
      wait_for_ajax

      expect(lesson.reload.activity).to eql(new_activity)

      expect(page).to have_content(new_activity)
    end

    scenario "Add places on a full lesson and send notification email", js: true do
      FactoryBot.create(:notification, sourceable_type: "Lesson", sourceable_id: lesson.id)
      lesson.update_attribute(:max_spots, 0)
      new_max_spots = 5
      emails_count = email_queue.size

      visit admin_lessons_path(location: 'moliere')

      page.find("#lesson_#{lesson.id}").click
      wait_for_ajax

      fill_in 'lesson_max_spots', with: new_max_spots

      page.execute_script "$('#lesson_submit').trigger('click')"
      wait_for_ajax

      expect(lesson.reload.max_spots).to eql(new_max_spots)
      expect(email_queue.size).to eql emails_count + 1
    end

    scenario "Deleting a lesson", js: true do
      visit admin_lessons_path(location: 'moliere')

      page.find("#lesson_#{lesson.id}").click

      page.accept_confirm do
        expect(page).to have_css("#destroy_lesson_#{lesson.id}")
        page.execute_script "$('#destroy_lesson_#{lesson.id}').trigger('click')"
      end

      wait_for_ajax

      expect(page).not_to have_css('#lesson_form')

      # Remove residual popovers
      page.execute_script %{$('.popover').remove()}

      #expect(page).not_to have_text(lesson.activity)

      expect(Lesson.exists?(lesson.id)).to be false
    end
  end

  context "logged in as a user" do
    before { login_as(:user) }

    scenario 'Accessing the index' do
      visit admin_lessons_path(location: 'moliere')

      expect(current_path).not_to eql(admin_lessons_path)
      assert_flash_presence 'access_denied'
    end
  end
end
