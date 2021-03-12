require 'rails_helper'

describe User, type: :model do
  it { is_expected.to have_many(:orders) }
  it { is_expected.to have_many(:subscriptions) }
  it { is_expected.to have_many(:payments) }
  it { is_expected.to have_many(:user_images) }
  it { is_expected.to have_many(:credit_cards) }
  it { is_expected.to have_many(:sponsored_users) }
  it { is_expected.to have_many(:lesson_bookings) }
  it { is_expected.to have_many(:visits) }
  it { is_expected.to have_many(:card_scans) }
  it { is_expected.to have_many(:invoices) }
  it { is_expected.to have_many(:notifications) }
  it { is_expected.to have_many(:mandates) }

  it { is_expected.to belong_to(:current_deferred_invoice) }
  it { is_expected.to belong_to(:current_credit_card) }
  it { is_expected.to belong_to(:profile_user_image) }
  it { is_expected.to belong_to(:sponsor) }

  describe "email validations" do
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to allow_value('example@test.com').for(:email) }
    it { is_expected.not_to allow_value('exampletest.com').for(:email) }

    context 'given an existing user' do
      subject { FactoryBot.build(:user) }
      it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
    end
  end

  describe "email formatting" do
    before do
      subject.email = ' User@example.Com'
      subject.valid?
    end

    describe '#email' do
      it { expect(subject.email).to eq('user@example.com') }
    end
  end

  describe "password validations" do
    subject { FactoryBot.build(:user, password: nil, password_confirmation: nil) }

    it { is_expected.to validate_presence_of(:password) }

    it "should validate the password confirmation" do
      subject.password = 'something1234'
      subject.password_confirmation = 'something else'

      expect(subject).not_to be_valid
      expect(subject.errors[:password_confirmation]).not_to be_empty
    end

    it "should validate the password complexity" do
      subject.password = '1234'
      subject.password_confirmation = '1234'

      expect(subject).not_to be_valid
      expect(subject.errors[:password]).not_to be_empty

      subject.password = 'abcd1234'
      subject.password_confirmation = 'abcd1234'

      expect(subject).to be_valid
    end

    context "with an existing User" do
      subject { FactoryBot.create(:user) }

      it "should not validate password presence" do
        subject.password = nil
        expect(subject).to be_valid
      end
    end
  end

  describe 'url validations' do
    subject { FactoryBot.build(:user) }

    it { is_expected.to allow_value(nil).for(:facebook_url) }
    it { is_expected.not_to allow_value('http://').for(:facebook_url) }
    it { is_expected.not_to allow_value('whatever').for(:facebook_url) }
    it { is_expected.to allow_value('https://www.facebook.com/profile/mylogin').for(:facebook_url) }
    it { is_expected.to allow_value('facebook.com/profile/mylogin').for(:facebook_url) }
    it { is_expected.to allow_value('fr-fr.facebook.com/profile/mylogin').for(:facebook_url) }
    it { is_expected.not_to allow_value('htp://fr-fr.facebook.com/profile/mylogin').for(:facebook_url) }
    it { is_expected.not_to allow_value('fr-fr.fake.facebook.com/profile/mylogin').for(:facebook_url) }

    it { is_expected.to allow_value(nil).for(:linkedin_url) }
    it { is_expected.not_to allow_value('https://').for(:linkedin_url) }
    it { is_expected.not_to allow_value('no info').for(:linkedin_url) }
    it { is_expected.to allow_value('https://www.linkedin.com/profile/mylogin').for(:linkedin_url) }
    it { is_expected.to allow_value('linkedin.com/profile/mylogin').for(:linkedin_url) }
    it { is_expected.to allow_value('fr.linkedin.com/profile/mylogin').for(:linkedin_url) }
    it { is_expected.to allow_value('http://lnkd.in/foobar').for(:linkedin_url) }
    it { is_expected.not_to allow_value('htp://fr.linkedin.com/profile/mylogin').for(:linkedin_url) }
    it { is_expected.not_to allow_value('fr.fake.linkedin.com/profile/mylogin').for(:linkedin_url) }
  end

  describe "card_reference validations" do
    it { is_expected.to allow_value(SecureRandom.hex(8).upcase, nil).for(:card_reference) }
    it { is_expected.not_to allow_value('ABCD').for(:card_reference) }
    it { is_expected.not_to allow_value('123456789 123456').for(:card_reference) }
  end

  describe "card_reference uniqueness validation" do
    subject { FactoryBot.build(:user, card_reference: '123456789ABDEFAA') }
    it { is_expected.to validate_uniqueness_of(:card_reference).case_insensitive }
  end

  describe "user validations" do
    it { is_expected.to validate_presence_of(:firstname) }
    it { is_expected.to validate_presence_of(:lastname) }

    it { is_expected.to validate_presence_of(:street1) }
    it { is_expected.to validate_presence_of(:postal_code) }
    it { is_expected.to validate_presence_of(:city) }

    it { is_expected.to validate_presence_of(:phone) }

    it { is_expected.to validate_presence_of(:birthdate) }
    it { is_expected.to validate_presence_of(:gender) }
  end

  describe "staff validations" do
    before { subject.role = :staff }

    it { is_expected.to validate_presence_of(:firstname) }
    it { is_expected.to validate_presence_of(:lastname) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_presence_of(:card_reference) }

    it { is_expected.not_to validate_presence_of(:password) }

    it { is_expected.not_to validate_presence_of(:city) }
  end

  describe "admin validations" do
    before { subject.role = :admin }

    it { is_expected.to validate_presence_of(:firstname) }
    it { is_expected.to validate_presence_of(:lastname) }
    it { is_expected.to validate_presence_of(:email) }

    it { is_expected.not_to validate_presence_of(:card_reference) }

    it { is_expected.to validate_presence_of(:password) }

    it { is_expected.not_to validate_presence_of(:city) }
  end

  describe "role" do
    it { is_expected.to enumerize(:role).in(:user, :admin, :staff).with_default(:user) }
  end

  describe "gender" do
    it { is_expected.to enumerize(:gender).in(:male, :female) }
  end

  describe '#current_subscription' do
    subject { FactoryBot.create(:user) }

    context 'when the user has no subscription' do
      describe '#current_subscription' do
        it { expect(subject.current_subscription).to be_nil }
      end
    end

    context 'when the user has a pending subscription' do
      before do
        FactoryBot.create(:subscription, user: subject)
      end

      describe '#current_subscription' do
        it { expect(subject.current_subscription).to be_nil }
      end
    end

    context 'when the user has a running subscription' do
      let(:subscription) { FactoryBot.create(:subscription, user: subject) }

      before do
        subscription.start!
      end

      it "should return the running subscription" do
        expect(subject.current_subscription).to eql(subscription)
      end
    end
  end

  describe "#card_admin_access?" do
    context "when the user is an admin user" do
      before { subject.role = 'admin' }

      describe '#card_admin_access?' do
        it { expect(subject.card_admin_access?).to be true }
      end
    end

    context "when the user is a staff user" do
      before { subject.role = 'staff' }

      describe '#card_admin_access?' do
        it { expect(subject.card_admin_access?).to be true }
      end
    end

    context "when the user is a standard user" do
      before { subject.role = 'user' }

      describe '#card_admin_access?' do
        it { expect(subject.card_admin_access?).to be false }
      end
    end
  end

  describe '#current_visit' do
    subject { FactoryBot.create(:user) }

    context 'with no visit in progress for the user' do
      let!(:visit) { FactoryBot.create(:visit, user: subject) }

      specify { expect(subject.current_visit).to be_nil }
    end

    context 'with a visit in progress for the user' do
      let!(:visit) { FactoryBot.create(:visit, :in_progress, user: subject) }

      specify { expect(subject.current_visit).to eql(visit) }
    end
  end

  describe '#has_upcoming_lessons?' do
    subject { FactoryBot.create(:user) }

    context "when the user has booked an upcoming lesson" do
      before do
        LessonBooking.create!(user: subject, lesson: FactoryBot.create(:lesson))
      end

      describe '#has_upcoming_lessons?' do
        it { expect(subject.has_upcoming_lessons?).to be true }
      end
    end

    context "when the user booked a past lesson" do
      before do
        past_lesson = FactoryBot.create(:lesson)
        LessonBooking.create!(user: subject, lesson: past_lesson)
        past_lesson.update_attributes!(start_at: Time.now - 20.hours)
      end

      describe '#has_upcoming_lessons?' do
        it { expect(subject.has_upcoming_lessons?).to be false }
      end
    end
  end

  describe '#card_access_authorized?' do
    subject { FactoryBot.create(:user) }

    context 'with card_access set to "authorized"' do
      before do
        subject.update_attributes(card_access: :authorized)
      end

      it { expect(subject.card_access_authorized?).to be true }
    end

    context 'with card_access set to "forbidden"' do
      before do
        subject.update_attributes(card_access: :forbidden)
      end

      it { expect(subject.card_access_authorized?).to be false }

      context 'as an admin user' do
        before { subject.role = 'admin' }

        it { expect(subject.card_access_authorized?).to be true }
      end

      context 'as a staff user' do
        before { subject.role = 'staff' }

        it { expect(subject.card_access_authorized?).to be true }
      end
    end
  end

  describe '.active and .inactive' do
    let!(:active_users) { FactoryBot.create_list(:user, 10) }
    let!(:inactive_users) { FactoryBot.create_list(:user, 5) }

    before do
      active_users.each { |user| FactoryBot.create(:subscription, user: user, state: 'running') }
    end

    it '.active returns users with running subscriptions' do
      expect(User.active.sort).to eql active_users.sort
    end

    it '.inactive returns users with running subscriptions' do
      expect(User.inactive.sort).to eql inactive_users.sort
    end
  end

  describe '.has_late_payments?' do
    let!(:user_with_late_payment) { FactoryBot.create(:user) }
    let!(:user_without_late_payment) { FactoryBot.create(:user) }

    before do
      invoice_pending  = FactoryBot.create(:invoice, state: :pending_payment, user: user_with_late_payment)
      invoice_pending.payments << FactoryBot.create(:payment, :with_credit_card, state: :declined)

      FactoryBot.create(:invoice, state: :paid, user: user_without_late_payment)
      invoice_pending.payments << FactoryBot.create(:payment, :with_credit_card)
    end

    it { expect(user_with_late_payment.has_late_payments?).to be true }
    it { expect(user_without_late_payment.has_late_payments?).to be false }
  end

  describe '.update_access_to_planning!' do
    let!(:user) { FactoryBot.create(:user) }
    let!(:user_with_no_planning_access) { FactoryBot.create(:user) }

    before { user.update_access_to_planning!(true) }

    it { expect(user_with_no_planning_access.force_access_to_planning).to be false }

    it { expect(user.force_access_to_planning).to be true }
  end

  describe '.update_access_to_planning!' do
    let!(:user) { FactoryBot.create(:user) }
    let!(:user_with_mandates_ready) { FactoryBot.create(:user, :with_mandate) }
    let!(:user_with_force_access_to_planning) { FactoryBot.create(:user) }
  
    let!(:subscription) { FactoryBot.create :subscription, :running, user: user }
    let!(:mand_subscription) { FactoryBot.create :subscription, :running, user: user_with_mandates_ready }
    let!(:forc_subscription) { FactoryBot.create :subscription, :running, user: user_with_force_access_to_planning }
  
    before do
      user_with_force_access_to_planning.update_access_to_planning!(true)
      user_with_mandates_ready.save!
      user_with_force_access_to_planning.save!
    end
    
    it { expect(user.has_access_to_planning?).to be false }
    it { expect(user_with_mandates_ready.has_access_to_planning?).to be true }
    it { expect(user_with_force_access_to_planning.has_access_to_planning?).to be true }
  end

  describe '.not_visiting' do
    let!(:visiting_user) { FactoryBot.create(:user) }
    let!(:absent_user) { FactoryBot.create(:user) }
    let!(:new_user) { FactoryBot.create(:user) }

    before do
      FactoryBot.create(:visit, user: visiting_user)
      FactoryBot.create(:visit, :in_progress, user: visiting_user)
      FactoryBot.create(:visit, user: absent_user)
    end

    it 'returns absent users' do
      expect(User.not_visiting).not_to include(visiting_user)
      expect(User.not_visiting).to include(absent_user)
      expect(User.not_visiting).to include(new_user)
    end
  end

  describe 'uniq_planning_access_bypass' do
    let!(:user) { FactoryBot.create(:user, :with_mandate) }
    it 'invalidates the user fo both bypass values are true' do
      expect(user).to be_valid

      user.forbid_access_to_planning = true
      user.force_access_to_planning = true
      expect(user).not_to be_valid
    end
  end
end
