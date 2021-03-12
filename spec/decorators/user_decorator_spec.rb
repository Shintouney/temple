require 'rails_helper'

describe UserDecorator do
  let(:user) { FactoryBot.build(:user) }
  subject { UserDecorator.decorate(user) }

  describe '#full_name' do
    describe '#full_name' do
      it { expect(subject.full_name).to match(user.lastname) }
    end

    describe '#full_name' do
      it { expect(subject.full_name).to match(user.firstname) }
    end
  end

  describe '#profile_image_thumbnail' do
    let(:user) { FactoryBot.create(:user) }

    context "without an existing profile image" do
      describe '#profile_image_thumbnail' do
        it { expect(subject.profile_image_thumbnail).to match('default-user-profile-image') }
      end
    end

    context "with an existing profile image" do
      let!(:user_image) { FactoryBot.create(:user_image, user: user) }
      before do
        user.update_attribute :profile_user_image, user_image
      end

      describe '#profile_image_thumbnail' do
        it { expect(subject.profile_image_thumbnail).to include(user_image.image.url(:thumbnail)) }
      end
    end
  end

  describe '#profile_image_miniature' do
    let(:user) { FactoryBot.create(:user) }

    context "without an existing profile image" do
      describe '#profile_image_miniature' do
        it { expect(subject.profile_image_miniature).to match('default-user-profile-image') }
      end
    end

    context "with an existing profile image" do
      let!(:user_image) { FactoryBot.create(:user_image, user: user) }
      before do
        user.update_attribute :profile_user_image, user_image
      end

      describe '#profile_image_miniature' do
        it { expect(subject.profile_image_miniature).to include(user_image.image.url(:miniature)) }
      end
    end
  end

  describe '#committed?' do
    context 'with a running subscription with a commitment period' do
      before do
        FactoryBot.create(:subscription, user: user, commitment_period: 3, state: 'running')
      end

      specify { expect(subject.committed?).to be true }
    end

    context 'with a running subscription without a commitment period' do
      before do
        FactoryBot.create(:subscription, user: user, commitment_period: 2, state: 'replaced')
        FactoryBot.create(:subscription, user: user, commitment_period: 0, state: 'running')
      end

      specify { expect(subject.committed?).to be false }
    end
  end

  describe '#payments_up_to_date?' do
    context 'without a pending payment retry invoice' do
      let!(:invoice) { FactoryBot.create(:invoice, state: 'pending_payment', user: subject) }

      describe '#payments_up_to_date?' do
        it { expect(subject.payments_up_to_date?).to be true }
      end
    end

    context 'with a pending payment retry invoice' do
      let!(:invoice) { FactoryBot.create(:invoice, state: 'pending_payment_retry', user: subject) }

      describe '#payments_up_to_date?' do
        it { expect(subject.payments_up_to_date?).to be false }
      end
    end
  end

  describe '#current_subscription_plan' do
    let(:user) { FactoryBot.create(:user) }

    context 'when the user has no subscription' do
      describe '#current_subscription_plan' do
        it { expect(subject.current_subscription_plan).to be_nil }
      end
    end

    context 'when the user has a running subscription' do
      let(:subscription_plan) { FactoryBot.create(:subscription_plan) }
      let(:subscription) { FactoryBot.create(:subscription, user: user, subscription_plan: subscription_plan) }

      before do
        subscription.start!
      end

      it "should return the decorated subscription plan" do
        expect(subject.current_subscription_plan.id).to eql(subscription_plan.id)
        expect(subject.current_subscription_plan).to be_a(SubscriptionPlanDecorator)
      end
    end
  end

  describe '#updatable_subscription_plans' do
    let(:user) { FactoryBot.create(:user) }
    let!(:alternate_subscription_plans) { FactoryBot.create_list(:subscription_plan, 2).sort_by(&:name) }

    context 'when the user has no subscription' do
      it "should return all subscription plans" do
        expect(subject.updatable_subscription_plans.to_a).to eql(alternate_subscription_plans)
      end
    end

    context 'when the user has a running subscription' do
      let(:subscription_plan) { FactoryBot.create(:subscription_plan) }
      let(:subscription) { FactoryBot.create(:subscription, user: user, subscription_plan: subscription_plan) }

      before do
        subscription.start!
      end

      it "should return all subscription plans except the curent subscription plan" do
        expect(subject.updatable_subscription_plans.to_a).to eql(alternate_subscription_plans)
      end
    end
  end

  describe '#current_orders' do
    let(:user) { FactoryBot.create(:user) }

    context 'when the user has orders created during this month' do
      before do
        15.times do
          order = FactoryBot.create(:order, user: user)
          order.update_attribute :created_at, (Time.now.beginning_of_month + rand(1..5).days)
        end
      end

      it 'should return a limited collection of orders' do
        current_orders = subject.current_orders

        expect(current_orders.length).to eql(10)
        expect(current_orders.first).to be_a(OrderDecorator)
      end
    end

    context 'when the user has no order created during this month' do
      before do
        2.times do
          order = FactoryBot.create(:order, user: user)
          order.update_attribute :created_at, (Time.now.beginning_of_month - rand(1..5).days)
        end
      end

      describe '#current_orders' do
        it { expect(subject.current_orders).to be_empty }
      end
    end
  end

  describe '#current_month_orders_count' do
    let(:user) { FactoryBot.create(:user) }

    context 'when the user has orders created during this month' do
      before do
        15.times do
          order = FactoryBot.create(:order, user: user)
          order.update_attribute :created_at, (Time.now.beginning_of_month + rand(1..5).days)
        end
      end

      describe '#current_month_orders_count' do
        it { expect(subject.current_month_orders_count).to eql(15) }
      end
    end

    context 'when the user has no order created during this month' do
      before do
        2.times do
          order = FactoryBot.create(:order, user: user)
          order.update_attribute :created_at, (Time.now.beginning_of_month - rand(1..5).days)
        end
      end

      describe '#current_month_orders_count' do
        it { expect(subject.current_month_orders_count).to eql(0) }
      end
    end
  end

  describe '#latest_orders' do
    let(:user) { FactoryBot.create(:user) }

    context 'when the user has orders' do
      let!(:orders) { FactoryBot.create_list(:order, 4, user: user) }

      it 'should return a limited collection of decorated orders' do
        latest_orders = subject.latest_orders

        expect(latest_orders.length).to eql(3)
        expect(latest_orders.first).to be_a(OrderDecorator)
      end
    end

    context 'when the user has no order' do
      describe '#latest_orders' do
        it { expect(subject.latest_orders).to be_empty }
      end
    end
  end

  describe '#last_payment' do
    let(:user) { FactoryBot.create(:user) }

    context 'when the user has payments' do
      let!(:payments) { FactoryBot.create_list(:payment, 2, :with_credit_card, user: user) }

      describe '#last_payment' do
        it { expect(subject.last_payment).to eql(payments.last) }
      end
    end

    context 'when the user has no payment' do
      describe '#last_payment' do
        it { expect(subject.last_payment).to be_nil }
      end
    end
  end

  describe '#next_lesson_booking' do
    let(:user) { FactoryBot.create(:user) }

    context 'when the user has a LessonBooking in the future' do
      let!(:lesson) { FactoryBot.create(:lesson) }
      let!(:lesson_booking) { FactoryBot.create(:lesson_booking, user: user, lesson: lesson) }

      it "should return the decorated LessonBooking" do
        expect(subject.next_lesson_booking.id).to eql(lesson_booking.id)
        expect(subject.next_lesson_booking).to be_a(LessonBookingDecorator)
      end
    end

    context 'when the user has a LessonBooking in the past' do
      let!(:lesson) { FactoryBot.create(:lesson) }
      let!(:lesson_booking) { FactoryBot.create(:lesson_booking, user: user, lesson: lesson) }

      before { lesson.update_attributes!(start_at: Date.yesterday.beginning_of_day) }

      describe '#next_lesson_booking' do
        it { expect(subject.next_lesson_booking).to be_nil }
      end
    end

    context 'when the user has no LessonBooking' do
      describe '#next_lesson_booking' do
        it { expect(subject.next_lesson_booking).to be_nil }
      end
    end
  end

  describe '#last_visit_started_at' do
    let(:user) { FactoryBot.create(:user) }

    context "without any ended visit" do
      describe '#last_visit_started_at' do
        it { expect(subject.last_visit_started_at).to eql('/') }
      end
    end

    context "with visits" do
      let!(:visit1) { FactoryBot.create(:visit, user: user, started_at: "2011-01-01 12:00:00", ended_at: "2011-01-01 13:00:00") }
      let!(:visit1) { FactoryBot.create(:visit, user: user, started_at: "2012-01-01 12:00:00", ended_at: "2012-01-01 13:00:00") }
      let!(:current_visit) { FactoryBot.create(:visit, :in_progress, user: user, started_at: "2013-01-01 12:00:00") }

      describe '#last_visit_started_at' do
        it { expect(subject.last_visit_started_at).to match('2012') }
      end
    end
  end

  describe '#autocomplete_link' do
    before do
      user.firstname = 'Some'
      user.lastname = 'One'
    end

    it 'returns an HTML link String' do
      expect(subject.autocomplete_link).to match("<a")
      expect(subject.autocomplete_link).to match(user.firstname)
    end
  end

  describe '#as_json_for_autocomplete' do
    before do
      user.id = 1432
      user.firstname = 'Some'
      user.lastname = 'One'
    end

    it 'returns a filtered Hash' do
      expect(subject.as_json_for_autocomplete[:id]).to eql(1432)
      expect(subject.as_json_for_autocomplete[:value]).to eql(subject.full_name)
      expect(subject.as_json_for_autocomplete[:link]).to match("<a")
    end
  end
end
