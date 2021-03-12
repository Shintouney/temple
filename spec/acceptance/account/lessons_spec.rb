require 'acceptance/acceptance_helper'

feature "User lessons" do
  context "logged in as a user", js: true do
    let!(:user) { FactoryBot.build(:user, :with_registered_credit_card, force_access_to_planning: true) }
    let!(:lesson) { FactoryBot.create :lesson, start_at: (Time.zone.now.at_beginning_of_day.advance(weeks: 1, hours: 14)) }

    before do
      login_with(user)
      FactoryBot.create(:subscription, user: user, state: 'running')
    end

    scenario 'Accessing the index without default location', js: true do
      visit account_lessons_path
      expect(current_path).to eql(account_lessons_path)
    end

    scenario 'Accessing the index', js: true do
      visit account_lessons_path(location: 'moliere')
      expect(current_path).to eql(account_lessons_path)

      expect(lesson.activity).not_to eq nil
      expect(page).to have_css('button.fc-button')
      expect(page).to have_css('button.fc-next-button')
      expect(page).not_to have_text(lesson.activity)

      find('.fc-next-button').click
      expect(page).to have_text(lesson.activity)

      find('.fc-next-button').click
      expect(page).not_to have_text(lesson.activity)
    end

    context 'has not access to planning' do
      before do
        user.force_access_to_planning = false
        user.forbid_access_to_planning = true
        user.save!
      end

       scenario 'is redirected to account_root_path' do
        visit account_lessons_path
        expect(current_path).to eq(account_root_path)
        assert_flash_presence "Vous n'avez pas accès au planning. Veuillez contacter l'administrateur du site."
      end
    end
  end

  context "logged in as an admin" do
    before { login_as(:admin) }

    scenario 'Accessing the index' do
      visit account_lessons_path(location: 'moliere')

      expect(current_path).to eql(admin_root_path)
      assert_flash_presence 'access_unavailable'
    end
  end

  context "not logged in" do
    scenario 'Accessing the index' do
      visit account_lessons_path(location: 'moliere')

      expect(current_path).to eql(login_path)
    end
  end
end
