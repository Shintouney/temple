require 'acceptance/acceptance_helper'

feature 'Admin lesson drafts management', type: :feature do
  context "logged in as an admin" do
    before { login_as(:admin) }

    let!(:lesson_draft) { FactoryBot.create(:lesson_draft) }

    scenario 'Accessing the index', js: true do
      visit admin_lesson_drafts_path(location: 'moliere')

      expect(page).to have_text(lesson_draft.activity)
    end

    scenario "Trying to create a lesson draft", js: true do
      lesson_draft_count = LessonDraft.count

      visit admin_lesson_drafts_path(location: 'moliere')

      click_link "new_lesson_draft"
      wait_for_ajax

      expect(page).to have_css('#lessonModal form')
      page.execute_script "$('#lesson_draft_submit').trigger('click')"

      expect(page).to have_css('#lessonModal .has-error')
      expect(LessonDraft.count).to eql(lesson_draft_count)
    end

    scenario "Creating a lesson draft", js: true do
      lesson_draft_count = LessonDraft.count
      lesson_draft_build = FactoryBot.build(:lesson_draft, activity: "Foobaring")

      visit admin_lesson_drafts_path(location: 'moliere')

      click_link "new_lesson_draft"
      wait_for_ajax

      select lesson_draft_build.room.text, from: 'lesson_draft_room'
      fill_in 'lesson_draft_coach_name', with: lesson_draft_build.coach_name
      fill_in 'lesson_draft_activity', with: lesson_draft_build.activity
      select I18n.t('date.day_names').sample, from: 'lesson_draft_weekday'

      page.execute_script "$('#lesson_draft_start_at_hour').val('#{lesson_draft_build.start_at_hour}')"
      page.execute_script "$('#lesson_draft_end_at_hour').val('#{lesson_draft_build.end_at_hour}')"

      page.execute_script "$('#lesson_draft_submit').trigger('click')"

      expect(page).to have_text(lesson_draft_build.activity)

      expect(LessonDraft.count).to eql(lesson_draft_count + 1)
    end

    scenario "Failing to edit a lesson draft", js: true do
      visit admin_lesson_drafts_path(location: 'moliere')

      page.find("#lesson_draft_#{lesson_draft.id}").click
      wait_for_ajax

      fill_in 'lesson_draft_activity', with: ''

      page.execute_script "$('#lesson_draft_edit_submit').trigger('click')"

      expect(page).to have_css('#lessonModal .has-error')
    end

    scenario "Editing a lesson draft", js: true do
      new_activity = "Mixed Martial Arts"

      visit admin_lesson_drafts_path(location: 'moliere')

      page.find("#lesson_draft_#{lesson_draft.id}").click
      wait_for_ajax

      fill_in 'lesson_draft_activity', with: ''
      fill_in 'lesson_draft_activity', with: new_activity

      page.execute_script "$('#lesson_draft_edit_submit').trigger('click')"

      expect(page).to have_text(new_activity)
      expect(lesson_draft.reload.activity).to eql(new_activity)
    end

    scenario "Deleting a lesson draft", js: true do
      visit admin_lesson_drafts_path(location: 'moliere')
      save_screenshot("screen1.png", { width: 1920, height: 1080 })
      page.find("#lesson_draft_#{lesson_draft.id}").click

      page.accept_confirm do
        expect(page).to have_css("#destroy_lesson_draft_#{lesson_draft.id}")
        save_screenshot("screen2.png", { width: 1920, height: 1080 })
        page.execute_script "$('#destroy_lesson_draft_#{lesson_draft.id}').trigger('click')"
      end

      save_screenshot("screen3.png", { width: 1920, height: 1080 })
      # Remove residual popovers
      page.execute_script %{$('.popover').remove()}

      save_screenshot("screen4.png", { width: 1920, height: 1080 })
      #expect(page).not_to have_text(lesson_draft.activity)
      expect(LessonDraft.exists?(lesson_draft.id)).to be false
    end
  end

  context "logged in as a user" do
    before { login_as(:user) }

    scenario 'Accessing the index' do
      visit admin_lesson_drafts_path(location: 'moliere')

      expect(current_path).not_to eql(admin_lesson_drafts_path)
      assert_flash_presence 'access_denied'
    end
  end
end
