require 'acceptance/acceptance_helper'

feature 'Admin lesson templates management', type: :feature do
  context "logged in as an admin" do
    before { login_as(:admin) }

    let!(:lesson_template) { FactoryBot.create(:lesson_template) }

    scenario 'Accessing the index', js: true do
      visit admin_lesson_templates_path(location: 'moliere')

      expect(page).to have_text(lesson_template.activity)
    end

    scenario "Trying to create a lesson template", js: true do
      lesson_template_count = LessonTemplate.count

      visit admin_lesson_templates_path(location: 'moliere')

      click_link "new_lesson_template"
      wait_for_ajax

      expect(page).to have_css('#lessonModal form')
      page.execute_script "$('#lesson_template_submit').trigger('click')"
      wait_for_ajax

      expect(page).to have_css('#lessonModal .has-error')

      expect(LessonTemplate.count).to eql(lesson_template_count)
    end

    scenario "Creating a lesson template", js: true do
      lesson_template_count = LessonTemplate.count
      lesson_template_build = FactoryBot.build(:lesson_template, activity: "Foobaring")

      visit admin_lesson_templates_path(location: 'moliere')

      click_link "new_lesson_template"
      wait_for_ajax

      select lesson_template_build.room.text, from: 'lesson_template_room'
      fill_in 'lesson_template_coach_name', with: lesson_template_build.coach_name
      fill_in 'lesson_template_activity', with: lesson_template_build.activity
      select I18n.t('date.day_names').sample, from: 'lesson_template_weekday'

      page.execute_script "$('#lesson_template_start_at_hour').val('#{lesson_template_build.start_at_hour}')"
      page.execute_script "$('#lesson_template_end_at_hour').val('#{lesson_template_build.end_at_hour}')"

      page.execute_script "$('#lesson_template_submit').trigger('click')"
      wait_for_ajax

      expect(page).to have_text(lesson_template_build.activity)

      expect(LessonTemplate.count).to eql(lesson_template_count + 1)
    end

    scenario "Failing to edit a lesson template", js: true do
      visit admin_lesson_templates_path(location: 'moliere')

      page.find("#lesson_template_#{lesson_template.id}").click
      wait_for_ajax

      fill_in 'lesson_template_activity', with: ''

      page.execute_script "$('#lesson_template_edit_submit').trigger('click')"
      wait_for_ajax

      expect(page).to have_css('#lessonModal .has-error')
    end

    scenario "Editing a lesson template", js: true do
      new_activity = "Mixed Martial Arts"

      visit admin_lesson_templates_path(location: 'moliere')

      page.find("#lesson_template_#{lesson_template.id}").click
      wait_for_ajax

      fill_in 'lesson_template_activity', with: new_activity

      page.execute_script "$('#lesson_template_edit_submit').trigger('click')"
      wait_for_ajax

      expect(page).to have_text(new_activity)

      expect(lesson_template.reload.activity).to eql(new_activity)
    end

    scenario "Deleting a lesson template", js: true do
      visit admin_lesson_templates_path

      page.find("#lesson_template_#{lesson_template.id}").click
      wait_for_ajax

      expect(page).to have_css("#destroy_lesson_template_#{lesson_template.id}")
      page.accept_confirm do
        page.execute_script "$('#destroy_lesson_template_#{lesson_template.id}').trigger('click')"
        wait_for_ajax
      end

      # Remove residual popovers
      page.execute_script %{$('.popover').remove()}
      wait_for_ajax

      #expect(page).not_to have_text(lesson_template.activity)

      expect(LessonTemplate.exists?(lesson_template.id)).to be false
    end
  end

  context "logged in as a user" do
    before { login_as(:user) }

    scenario 'Accessing the index' do
      visit admin_lesson_templates_path(location: 'moliere')

      expect(current_path).not_to eql(admin_lesson_templates_path)
      assert_flash_presence 'access_denied'
    end
  end
end
