require 'acceptance/acceptance_helper'

feature 'Admin Announce management' do
  before { login_as(:user) }
  context "when a text announce is made" do
    let!(:announce) { FactoryBot.create(:announce, place: "dashboard", active: true) }
    scenario 'it show a clickable alert' do
      visit account_root_path
      expect(page.body).to have_content announce.content
    end
    context 'when a link is defined' do
      before do
        announce.target_link = 'google.com'
        announce.save!
      end
      scenario 'the alert content is clickable' do
        visit account_root_path
        expect(page.body).to have_content announce.content
        expect(page.body).to have_link(announce.content, href: 'http://google.com')
      end
    end
  end

  context 'when an image announce is made' do
    let!(:announce) { FactoryBot.create(:announce, :banner, place: "dashboard", active: true) }
    scenario 'it show a clickable image' do
      visit account_root_path
      expect(page.body).to have_css('.alert-animated')
    end
    context 'when a link is defined' do
      before do
        announce.target_link = 'google.com'
        announce.save!
      end
      scenario 'the image is clickable' do
        visit account_root_path
        expect(page.body).to have_xpath('//a[@href="http://google.com"]')
      end
    end
  end
end
