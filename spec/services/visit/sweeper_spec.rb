require 'rails_helper'

describe Visit::Sweeper do
  describe '#initialize' do
    let(:current_time) { DateTime.new(2014, 5, 2, 14, 30, 00) }

    before { Timecop.freeze(current_time) }
    after { Timecop.return }

    it "should load the obsolete visits in progress" do
      obsolete_visit_in_progress = FactoryBot.create(:visit, :in_progress, started_at: (current_time - 5.hours))
      FactoryBot.create(:visit, :in_progress, started_at: (current_time - 2.hours))
      FactoryBot.create(:visit)

      sweeper = Visit::Sweeper.new

      expect(sweeper.visits_in_progress.map(&:id)).to eql([obsolete_visit_in_progress.id])
    end
  end

  describe '#execute' do
    let(:current_time) { DateTime.new(2014, 5, 2, 14, 30, 00) }

    before { Timecop.freeze(current_time) }
    after { Timecop.return }

    let!(:finished_visits) { FactoryBot.create_list(:visit, 2) }
    let!(:obsolete_visit_in_progress) do
      FactoryBot.create(:visit, :in_progress, started_at: (current_time - 5.hours))
    end
    let!(:active_visits_in_progress) do
      FactoryBot.create_list(:visit, 2, :in_progress, started_at: (current_time - 2.hours))
    end

    it 'finishes the obsolete visit only' do
      subject.execute

      obsolete_visit_in_progress.reload
      active_visits_in_progress.map!(&:reload)

      expect(active_visits_in_progress.all?(&:in_progress?)).to be true

      expect(obsolete_visit_in_progress.in_progress?).to be false
      expect(obsolete_visit_in_progress.ended_at).to eql(obsolete_visit_in_progress.started_at + 3.hours)
    end
  end
end
