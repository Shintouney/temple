class CardScan
  class Create
    attr_reader :user, :card_scan

    def initialize(user, card_scan_params)
      @user = user
      @card_scan = user.card_scans.new(card_scan_params)
    end

    def execute
      if card_scan.save
        return true if !card_scan.accepted? or user.card_admin_access?

        if card_scan.scan_point_bar_entrance_moliere? || card_scan.scan_point_bar_entrance_maillot? || card_scan.scan_point_bar_entrance_amelot?
          create_visit
        elsif card_scan.scan_point_bar_exit_moliere? || card_scan.scan_point_bar_exit_maillot? || card_scan.scan_point_bar_exit_amelot?
          finish_current_visit
        end

        return true
      else
        return false
      end
    end

    private

    def create_visit
      user.visits.create(started_at: card_scan.scanned_at,
                         checkin_scan: card_scan, location: card_scan.location)
    end

    def finish_current_visit
      return unless user.current_visit

      user.current_visit.finish!(card_scan)
    end
  end
end
