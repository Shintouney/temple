class Data
  class InvoiceUserDix
    USER_LIST = %i(
	matthieu.hug@gmail.com
	philippe.hertanu@gmail.com
	lionel.klein.1@gmail.com
	mabouquin@gmail.com
	cclerc@kameleoon.com
	antonin.couillec@gmail.com
	plvincens@hotmail.com
	cdbproduction@yahoo.fr
	fr_vasiere@hotmail.com
	s.schapira@schapira-associes.eu
	joniddam@gmail.com
	niknai2003@hotmail.com
	richard.lorant@gmail.com
	alexgoltsova@gmail.com
	n.dumarcet@gmail.com
	arnaudclerc17@gmail.com
	f.long@hotmail.fr
	pierre.edouard.marty@gmail.com
	kev.pariente@gmail.com
	charlie@tempow.com
	mboukhris@msn.com
	nicolas.detchepare@yahoo.fr
	garyfinelle@gmail.com
	bertrand@wttj.co
	meizimaquillage@gmail.com
	ferreol.jade@gmail.com
	laurenthw@gmail.com
	stoessel.fabien@gmail.com
	franklin.henrot@gmail.com
	sfonsecasantos@yahoo.fr
	baptiste.aubour@gmail.com
	dsk.saffar@gmail.com
	celine.rag@hotmail.fr
	eliottzaq1@hotmail.fr
	esther.azoulay.rutman@gmail.com
	bernard.mathieu90@gmail.com
	henriguillaume_90@hotmail.com
	lioszno@gmail.com
	laureenbauer33@gmail.com
	myriam.ettayeb@gmail.com
	alardilleux@gmail.com
	fannychen.wrk@gmail.com
	alexpapineschi@gmail.com
	tiiimmber@gmail.com
	cerasiflavia@gmail.com
	julien.aguilar75@gmail.com
	nikulina.oleksandra@gmail.com
	alla.sofiane@hotmail.fr
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
        invoice.next_payment_at = Date.new(2020, 07, 10)
        invoice.end_at = Date.new(2020, 07, 10)
        invoice.save
      end
    end
  end
end
