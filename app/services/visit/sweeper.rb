class Visit::Sweeper
  VISIT_DURATION_LIMIT = 3.hours

  attr_reader :visits_in_progress

  # Public: Initializes a Visit::Sweeper object.
  #
  # Returns nothing.
  def initialize
    started_at_threshold = Time.now - VISIT_DURATION_LIMIT

    @visits_in_progress  = Visit.in_progress.where('started_at < ?', started_at_threshold)
  end

  # Public: Loops on every visit in progress to close
  # the ones with a duration longer than the limit.
  #
  # Returns nothing.
  def execute
    visits_in_progress.each do |visit|
      visit.finish! nil, (visit.started_at + VISIT_DURATION_LIMIT)
    end
  end
end
