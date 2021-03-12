class Data
  class InvoiceUserHuit
    USER_LIST = %i(

    fredtengelmann@hotmail.com
    amelie.molinski@gmail.com
    perrinhelene@wanadoo.fr
    boure.maxime@gmail.com
    scoothinano.therme@gmail.com
    pinelliadrien@hotmail.com
    yodelice1@gmail.com
    alex.kapusta@gmail.com
    cquesnel@oddo.fr
    olivier.fisch@gmail.com
    sebastien.tronel@gmail.com
    deferrari@gmail.com
    louis.ressaire@gmail.com
    alexandre@greenwichsocial.fr
    antoine.caro1@gmail.com
    thibault.wirth@gmail.com
    jsdavat@hotmail.com
    gui.chevillon@gmail.com
    xpignaud@gmail.com
    stphano@gmail.com
    aurore.zlatev@gmail.com
    dprincay@gmail.com
    sebastienbottreau@orange.fr
    john.pietri@gmail.com
    beatrice.boursier@orange.fr
    spamboud@gmail.com
    idrissmouliom@hotmail.com
    joachim.tobali@gmail.com
    deutsch.berenice@gmail.com
    laurenbaker15@gmail.com
    raphaeldumoutet@bredinprat.com
    mv.maximevogel@gmail.com
    amathieu44@gmail.com
    astridcossec@aol.com
    camillehubert@hotmail.com
    thibault.laure@sciencespo.fr
    a.burgermeister@burgermeister.fr
    thomas.dexet@gmail.com
    mariusamiel@protonmail.com
    auclair.arthur@gmail.com
    maylis.darricau@gmail.com
    blanc84570@gmail.com
    thomas.denizeau@gmail.com
    baptiste.lehetet@yahoo.fr
    pascale.gelb@sabre.fr
    francis.gelb@sabre.fr
    gregoiresaison@yahoo.fr
    indira.avdic@skadden.com
    guillaumemaurice03@gmail.com
    willahern7@gmail.com
    thomas.benoist.lucy@gmail.com
    joseph.collement@gmail.com
    julienlecoq2@gmail.com
    pierre.caussignac@gmail.com
    maximepenard@hotmail.fr
    ribesbenjamin@gmail.com
    chayana@recalltheapp.com
    alexgzuspitz@gmail.com
    lukawill77@gmail.com
    cavaleri@fastmail.fm
    kenzaberrane1990@hotmail.com
    coulomb_adrien@orange.fr
    lea.cichowlas@gmail.com
    octave.delannoy@gmail.com
    mejbri.malek@gmail.com
    anthonycalci@calci-patrimoine.com
    margauxfdf@gmail.com
    jean.nh.nguyen@gmail.com
    micka.sebban@gmail.com
    timothee.leguay@laposte.net
    audray.lorey@gmail.com
    lhoste.mathieu@gmail.com
    jeanchristophe.couderc@gmail.com
    guillaume@therollingshop.com
    yann.dupas@gmail.com
    jonathan.chlewicki@gmail.com
    senkivandrew@gmail.com
    richard.derrien@gmail.com
    julien.eric.perez@gmail.com
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
        invoice.next_payment_at = Date.new(2020, 07, 8)
        invoice.end_at = Date.new(2020, 07, 8)
        invoice.save
      end
    end
  end
end
