class Data
  class InvoiceUserVingt
    USER_LIST = %i(
      romainnoel@yahoo.fr
      damienbrochu@wanadoo.fr
      lezard@mfglabs.com
      brousse.benjamin@yahoo.fr
      jonathan@katchme.fr
      andrewchristophebrown@gmail.com
      pierre.gastineau@gmail.com
      jeremybenatar@gmail.com
      gsardin@ubisoft.fr
      t.lecointe@me.com
      arnaudbellamy@gmail.com
      carole.myself@gmail.com
      alayanurpujol@gmail.com
      faustine773@hotmail.fr
      mlahencina@gmail.com
      julie.gruner@hotmail.fr
      anthony.murgia@gmail.com
      emyjones.art@gmail.com
      lisascarpa@mac.com
      durand.cyril1@voila.fr
      derniercris@gmail.com
      yanis.escudero@gmail.com
      sebastien.lorrain@cbre.fr
      amany.chamieh@gmail.com
      mathieu.ghanem@gmail.com
      revauxfrancois@gmail.com
      98theobeguin@gmail.com
      paulyvart@gmail.com
      ruling.zeng@hotmail.com
      martin.bonnier@icloud.com
      rodrigue.vundilu@hotmail.com
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
        invoice.next_payment_at = Date.new(2020, 07, 20)
        invoice.end_at = Date.new(2020, 07, 20)
        invoice.save
      end
    end
  end
end
