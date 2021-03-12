require 'rails_helper'

describe AnnounceDecorator do
  let(:announce) { Announce.new }
  subject { AnnounceDecorator.decorate(announce) }

  describe "link" do
    context 'when the http prefix is not given' do
      before do
        announce.target_link = 'google.com'
      end
      specify{ expect(subject.link).to eql 'http://google.com' }
    end
    context 'when the http prefix is given' do
      before do
        announce.target_link = 'https://google.com'
      end
      specify{ expect(subject.link).to eql announce.target_link }
    end
  end

  describe "target" do
    specify { expect(subject.target).to eql '_self' }
  end

  describe "state" do
    context 'when the annouce is ready' do
      before do
        announce.start_at = Time.zone.now.advance(days: 2)
        announce.end_at = Time.zone.now.advance(days: 4)
      end
      specify{ expect(subject.state).to match I18n.t(:ready, scope: [:admin, :announces, :index, :state]) }
    end
    context 'when the announce is finished' do
      before do
        announce.start_at = Time.zone.now.advance(days: -2)
        announce.end_at = Time.zone.now.advance(days: -1)
      end
      specify{ expect(subject.state).to match I18n.t(:finished, scope: [:admin, :announces, :index, :state]) }
    end
    context 'when the annouce is launched' do
      before do
        announce.start_at = Time.zone.now.advance(days: -2)
        announce.end_at = Time.zone.now.advance(days: 2)
      end
      specify{ expect(subject.state).to match I18n.t(:launched, scope: [:admin, :announces, :index, :state]) }
    end
  end

  describe "active_tag" do
    context "when the announce is active" do
      before do
        announce.active = true
      end
      specify do
        expect(subject.active_tag).to match(
          "<i class=\"fa fa-check-circle text-success\" aria-label=\"#{I18n.t(:active, scope: [:admin, :announces, :index])}\"></i>"
        )
      end
    end
    context "when the announce is NOT active" do
      specify do
        expect(subject.active_tag).to match(
          "<i class=\"fa fa-times-circle muted\" aria-label=\"#{I18n.t(:not_active, scope: [:admin, :announces, :index])}\"></i>"
        )
      end
    end
  end

  describe "place_tag" do
    context "when announce is placed on all pages" do
      specify do
        expect(subject.place_tag).to match "<span class=\"label label-default\">"
      end
    end
    context "when announce is placed on dashboard" do
      before do
        announce.place = 'dashboard'
      end
      specify do
        expect(subject.place_tag).to match "<span class=\"label label-primary\">"
      end
    end
  end
end
