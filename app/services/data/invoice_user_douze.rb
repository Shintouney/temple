class Data
  class InvoiceUserDouze
    USER_LIST = %i(
    regis@digitalprod.com
    yongtaiwu@gmail.com
    romain.carles@gmail.com
    virgileviard@gmail.com
    alex.c.vargas@free.fr
    nleboennec@gmail.com
    pfrimbaud@gmail.com
    lucas.verrot@hotmail.fr
    charlie@charliejaniaut.com
    etienne.vimal@gmail.com
    colin.damie@gmail.com
    delphine.brossard.mail@gmail.com
    wjavocat@gmail.com
    delordolivia@gmail.com
    grieu.simon@gmail.com
    krondimitri@hotmail.com
    thibault.merc@gmail.com
    olivier.lingam@gmail.com
    meilingtalibart@yahoo.fr
    apvermynck@gmail.com
    allaindu@gmail.com
    sachapineda@gmail.com
    d.chouraki@gmail.com
    gabrielzafrani@gmail.com
    fredonvanessa@gmail.com
    d.laufer25@yahoo.fr
    charles.brisbois@orange.com
    fvalla@gmail.com
    harmancsh@hotmail.fr
    etiennedemoulins@gmail.com
    aurore@samaipata.vc
    youssefrezgui@gmail.com
    asinkylian@gmail.com
    g3t2ey@gmail.com
    julien.claude87@hotmail.fr
    fred.barczy@outlook.fr
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
        invoice.next_payment_at = Date.new(2020, 07, 12)
        invoice.end_at = Date.new(2020, 07, 12)
        invoice.save
      end
    end
  end
end
