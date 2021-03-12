class Data
  class InvoiceUserNeuf
    USER_LIST = %i(
    tmarx@mohg.com
    guillaumegibault@gmail.com
    ramdane@ramdane.com
    alex_botaya@hotmail.com
    aymeric@art-ev.com
    anatoletrefaut@yahoo.com
    m.riolacci@gmail.com
    nicolas.deloume@gmail.com
    maximehalimi@yahoo.fr
    cl.maximilien@gmail.com
    caroline.rudler@gmail.com
    benjaminpersitz@gmail.com
    qdelavigne@gmail.com
    jcopolata@gmail.com
    valerie.buscaglia@gmail.com
    carolau@wanadoo.fr
    sacha_mnm@hotmail.com
    noemie.elbaz1@gmail.com
    khakhouliazina@gmail.com
    y.santiago@hotmail.fr
    charlie_renier@hotmail.fr
    alexandre.hoffer@gmail.com
    quentin.bienvenue@rennes-sb.com
    jeancharles.sibeud@gmail.com
    edw.frk@gmail.com
    jhgrislain@gmail.com
    alexandre@4cs-consulting.com
    yuanxiaoyun0329@163.com
    arnaud.bosc@gmail.com
    montanari.stephane@wanadoo.fr
    raphael.velfre@gmail.com
    edouard.jounet@gmail.com
    thibault.hanotin@sfr.fr
    d.seroux@gmail.com
    arthur.faury@hotmail.fr
    emytis@me.com
    iul
    a.eremeeva@gmail.com
    schiff.xavier@gmail.com
    yannivgilquel@paulhastings.com
    ck_1@hotmail.fr
    gabriel.guery@gmail.com
    xavier.encinas@gmail.com
    c.mutsaerts@gmail.com
    perrinelebrun@gmail.com
    rpelosse@gmail.com
    paul.lorant@hotmail.fr
    tlupart@moethennessy.com
    guillaume.altain@gmail.com
    jeremy.poivredarvor@sciencespo.fr
    jason@kleinman.co.za
    florent.chen@gmail.com
    jrmydrs@gmail.com
    brillault.vincent@gmail.com
    franck.sayala@gmail.com
    pierre.sudries@ensae.org
    ouafaa95@gmail.com
    victor.ddc@hotmail.fr
    alicia.raulic@outlook.fr
    solal@delaage.net
    romjoyenval@hotmail.fr
    gunduz27@yahoo.fr
    gwendall.esnault@gmail.com
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
        invoice.next_payment_at = Date.new(2020, 07, 9)
        invoice.end_at = Date.new(2020, 07, 9)
        invoice.save
      end
    end
  end
end
