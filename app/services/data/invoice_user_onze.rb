class Data
  class InvoiceUserOnze
    USER_LIST = %i(

    jeannet@lacourte.com
    jchevy@free.fr
    david.de.jesus@sfr.fr
    francois.buhagiar@hotmail.com
    mathieu.cleach@gmail.com
    romgauthi@gmail.com
    danieldiot@yahoo.fr
    laurent.massot@gmail.com
    milouseba@gmail.com
    ol.gerstle@gmail.com
    jeromeboe@gmail.com
    khami.ed@gmail.com
    christofhuck@gmail.com
    nrocquet@ccomptes.fr
    davidghez@me.com
    pierrejean.perin@iscpalyon.net
    axelhauschild@gmail.com
    michelpuech25@gmail.com
    jochenhaegele@gmail.com
    dke2610@gmail.com
    avy.parisglamour@gmail.com
    donatienchenu@gmail.com
    thaleranne@gmail.com
    lucieiriswood@gmail.com
    thomaslenthal@gmail.com
    juliengamiette@hotmail.com
    pinna.marion@gmail.com
    julienrozorangel@gmail.com
    tournissoux.antoine@gmail.com
    f.bassnagel@gmail.com
    denis.machuel@orange.fr
    s.saby@hotmail.fr
    trankilforce@gmail.com
    chaput_th@yahoo.fr
    nouraboujaoude@gmail.com
    mahmodou@gmail.com
    pierre.arm@gmail.com
    fred.schmitt75@gmail.com
    mh.atoui@gmail.com
    matthieu@nannybag.com
    yphilippe45@gmail.com
    laurenedufosse@gmail.com
    qtn.dbr@gmail.com
    claire-greau@hotmail.fr
    py_nussbaum@yahoo.fr
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
        invoice.next_payment_at = Date.new(2020, 07, 11)
        invoice.end_at = Date.new(2020, 07, 11)
        invoice.save
      end
    end
  end
end
