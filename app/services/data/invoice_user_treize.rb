class Data
  class InvoiceUserTreize
    USER_LIST = %i(
    dom.nuyt@orange.fr
    monsieurlung@gmail.com
    elacheteau@gmail.com
    tom.karmann@gmail.com
    snps2018@gmail.com
    paule.fratacci@hotmail.fr
    julie.pichon1@gmail.com
    victor_bacque@hotmail.fr
    jonathancochet@yahoo.fr
    soradjoul@me.com
    sophie.perez1999@gmail.com
    j.andrez@ayachesalama.com
    hicham@klh-competence.com
    fialessandro@gmail.com
    jm.carlotti@orange.fr
    costalain@gmail.com
    allary.pierre@gmail.com
    carinacheklit@hotmail.fr
    isadora.defreitas@emea.shiseido.com
    hatet.louis@outlook.fr
    mendozaq.valeria@gmail.com
    mariem.mhadhbi@gmail.com
    elie.d.alexandre@gmail.com
    e.sztajman@gmail.fr
    lenoir.ninon@yahoo.fr
    placide_h@hotmail.fr
    sofia_allalou@yahoo.fr
    spinto_ribeiro@hotmail.com
    ndreyfus@hotmail.fr
    matthieu.gaillard@hotmail.fr
    doungemi4@gmail.com
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
        invoice.next_payment_at = Date.new(2020, 07, 13)
        invoice.end_at = Date.new(2020, 07, 13)
        invoice.save
      end
    end
  end
end
