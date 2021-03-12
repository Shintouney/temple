class Data
  class InvoiceUserQuinze
    USER_LIST = %i(
    yves.genouvrier@ardian-investment.com
    alexandrelemetais@gmail.com
    lambert.demange@gmail.com
    gbernard7@wanadoo.fr
    yoann.guillot@yahoo.com
    sophie_martin75@hotmail.com
    g.hemmerle@sigmagestion.com
    izabela.kwarcinska@dlapiper.com
    jeanbaptisterichard@live.fr
    boris.sebbag@gmail.com
    darifineart@gmail.com
    t.foucher1895@gmail.com
    emmanuellegilles1@hotmail.com
    vanessalecomte@me.com
    benjamin@napoleon-events.com
    talcaina@bfgcapital.com
    judith@digitalprod.com
    annelouisecloarec@gmail.com
    kcaliati@gmail.com
    svx@modenaconseil.com
    romain.baugue@gmail.com
    mguerin@institutmontaigne.org
    rbimmoconcept@gmail.com
    nadia.beauquis@gmail.com
    cduplessix@gmail.com
    g.nivault@gmail.com
    zerah@outlook.com
    mariececiletardieu@gmail.com
    alexandrezouari79@gmail.com
    nawfal.belmekki@gmail.com
    joel@dg-prod.com
    guillaume@monsieurguiz.fr
    caroline.span@gmail.com
    zarrouk.skander@gmail.com
    jacek.urban@hec.edu
    gvillatte@gmail.com
    jeremyabihssira@gmail.com
    pierre.delestrade@gmail.com
    c.bulliard@mailistec.fr
    regisjeremy@gmail.com
    jeremie@jaflalo.com
    nicolasyazman@gmail.com
  )

    def initialize()
      @user_list = USER_LIST
      @user_count = 0
    end

    def call
      check_invoices
    end

    private

    def check_invoices
      @invoices = []
      @user_list.each do |user|
        user = User.find_by_email user
        if user
          @invoices << user.invoices&.where.not(next_payment_at: nil).order('next_payment_at DESC').first
          check_if_user_has_sepa_waiting(user)
        end
      end
      return @user_count
    end

    def check_if_user_has_sepa_waiting(user)
      invoices = user.invoices.where('next_payment_at BETWEEN ? AND ?', Date.new(2020, "07".to_i, 1), DateTime.new(2020, 10, 31))
      if invoices&.first.present?
        @user_count = @user_count + 1
        puts invoices.first.next_payment_at
        puts invoices.first.state
        puts invoices.first.user.email
        update_invoice invoices.first
      end
    end

    def update_invoice invoice
      unless invoice.state == "sepa_waiting" || invoice.state == "paid"
        invoice.next_payment_at = Date.new(2020, 07, 15)
        invoice.end_at = Date.new(2020, 07, 15)
        invoice.save
      end
    end
  end
end
