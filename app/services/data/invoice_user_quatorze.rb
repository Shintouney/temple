class Data
  class InvoiceUserQuatorze
    USER_LIST = %i(
			gary.s.roth@gmail.com
			slavicek.marie@gmail.com
			milakiss6@gmail.com
			navarro.f.andres@gmail.com
			eliottdemontremy@gmail.com
			sam.azoulay@hotmail.fr
			yoann.fourel@gmail.com
			gmanach@outlook.fr
			xavier.chauvin@orange.fr
			fb.remaze@yahoo.fr
			nicolas.pasquet@makinov.fr
			xavier.crettiez@wanadoo.fr
			quentin.gomez@live.fr
			julien.fertouc@gmail.com
			raphael.chet@gmail.com
			davy.bureau@gmail.com
			meservices@free.fr
			stephane.bisiauxouteiral@cic.fr
			francois.lafaye@gmail.com
			barrabruno@yahoo.fr
			vince0905@gmail.com
			mdbaume@gmail.com
			jimmyjourno@gmail.com
			theo.michel@icart.fr
			lalbert@id-am.fr
			elodys@hotmail.com
			felixalfonsi@yahoo.fr
			wang.yueyue@hotmail.fr
			jeanph1406@icloud.com
			dodoguez@yahoo.fr
			cvallabriga@gmail.com
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
        invoice.next_payment_at = Date.new(2020, 07, 14)
        invoice.end_at = Date.new(2020, 07, 14)
        invoice.save
      end
    end
  end
end
