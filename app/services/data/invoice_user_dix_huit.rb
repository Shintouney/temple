class Data
  class InvoiceUserDixHuit
    USER_LIST = %i(
			coste-emmanuelle@orange.fr
			minetpaul@gmail.com
			haddad.nikola@gmail.com
			jgaretier@gmail.com
			hani.belahcene@gmail.com
			yumibebe35@hotmail.com
			eanisten@hotmail.com
			jul.cesar.ferrer@gmail.com
			jackrothert@gmail.com
			jeanbricetonin@gmail.com
			jeanchristophe.littaye@cmcic.fr
			mathilde.courboillet@gmail.com
			paddiuo@gmail.com
			tchavii@gmail.com
			thibault.marcaillou@gmail.com
			cyril.durand@coephe.com
			richardgilles@free.fr
			martin.duval@bluenove.com
			sebtisara@gmail.com
			jules.dubois2010@gmail.com
			jeanarthurbourdier@gmail.com
			picard.stephane@gmail.com
			noelcecile@outlook.com
			valentin.sarraf@gmail.com
			stevetordjman@hotmail.com
			rberenguier@gmail.com
			antoineleport0@gmail.com
			le.royer.servane@gmail.com
			marine.combes@ysl.com
			emiliehaccoun@gmail.com
			antony.randazzo@audiens.org
			sycheva@yahoo.com
			jeanmarc.bejani@gmail.com
			nora.harzallaoui@gmail.com
			martakiruthi@gmail.com
			marc_benelbaz@hotmail.com
			lenainpaulpl@gmail.com
			steevebitton@yahoo.fr
			suidanrudy4@gmail.com
			serge.pizem@axa-im.com
			leo.launay7@gmail.com
			remi.opryszko@gmail.com
			fanadimitri@gmail.com
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
        invoice.next_payment_at = Date.new(2020, 07, 18)
        invoice.end_at = Date.new(2020, 07, 18)
        invoice.save
      end
    end
  end
end
