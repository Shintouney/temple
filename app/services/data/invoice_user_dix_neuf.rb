class Data
  class InvoiceUserDixNeuf
    USER_LIST = %i(
    t.schwob@orange.fr
    pierre.reimpre@gmail.com
    wilshawb@gmail.com
    fchiche@me.com
    thomas.chandat@gmail.com
    david@pears.fr
    dvercollier@live.fr
    roman.martin7500@gmail.com
    huguesdelafortelle@gmail.com
    thibaut.gribelin@gmail.com
    florence.kunian@gmail.com
    florent_scheidgen@hotmail.com
    lenny_pin@hotmail.com
    giardi.coline@gmail.com
    collignon78@gmail.com
    charlotteabati@gmail.com
    stephane.bout@free.fr
    ephraimatlan@gmail.com
    melissa@yliko.com
    leca.olivier@gmail.com
    lepagedavid@hotmail.com
    fares.alhussami@gmail.com
    bourgeoisguillaume.j@gmail.com
    maximilien.marceau@gmail.com
    philippe.wg@gmail.com
    y.baser_92@hotmail.com
    johnalessandraa@gmail.com
    amandinegarnier@hotmail.com
    cyrille.reboul@gmail.com
    pascal@leclech.fr
    paul.belgacem@laposte.net
    selodie@hotmail.fr
    antoine.mr@gmail.com
    juliamalinbaum@gmail.com
    ganesh.jaikishan@gmail.com
    marine.lorphelin@outlook.fr
    olivier@hypevandals.com
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
        invoice.next_payment_at = Date.new(2020, 07, 19)
        invoice.end_at = Date.new(2020, 07, 19)
        invoice.save
      end
    end
  end
end
