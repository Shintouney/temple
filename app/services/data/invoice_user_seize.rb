class Data
  class InvoiceUserSeize
    USER_LIST = %i(
    rp@mpavocats.com
    phil@studiobleu.com
    gihan.bibi@hotmail.fr
    samsonstephane@yahoo.fr
    a.klein@lincolninternational.fr
    romhermel@yahoo.fr
    pierre.streicher@gmail.com
    willyzyl@gmail.com
    fabien.jouneau@gmail.com
    barbaraw@gmail.com
    thibaud.spinella@gmail.com
    jeanclaudebales@gmail.com
    maximekhindria@gmail.com
    gauthier.rivals@gmail.com
    bryanlugassy7@gmail.com
    franklin-frey@hotmail.fr
    scombaluzier@gmail.com
    besset.hugo@gmail.com
    n.valverde@hotmail.fr
    t.monthemont@gmail.com
    adrienbasdevant@gmail.com
    zak@wesave.fr
    yserrantlucas@gmail.com
    olivier@steam-one.com
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
        invoice.next_payment_at = Date.new(2020, 07, 16)
        invoice.end_at = Date.new(2020, 07, 16)
        invoice.save
      end
    end
  end
end
