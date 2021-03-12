class Data
  class InvoiceUserDixSept
    USER_LIST = %i(
    thomas@lenthal.com
    rsaintetienne@gmail.com
    alexis.blez@gmail.com
    gabriel.mauger30@gmail.com
    aucomptoirdesfleurs@orange.fr
    fsimon05@gmail.com
    louis.costamagna@gmail.com
    maxime.kahn@gmail.com
    dmhagge@gmail.com
    leo.ondas@gmail.com
    xavieryonter@hotmail.com
    a.pujolle@gmail.com
    hugo.ratero@scaledrisk.com
    nfinkelstein@wanadoo.fr
    mariefacchetti@hotmail.com
    rafael.quina@gmail.com
    renzhongjie83@gmail.com
    nader.bouss@yahoo.fr
    nico_pisu@msn.com
    louise.encontre@gmail.com
    anthony.gug@gmail.com
    sikhlef@ikeysdigital.com
    oliviermoulierac@me.com
    myriam.bensalah@gmail.com
    eeva.rousselle@hotmail.com
    juliendumesnil188@gmail.com
    rb@onyx-immobilier.com
    iliasouali@gmail.com
    johnericsonreyes@gmail.com
    onealex.c@gmail.com
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
        invoice.next_payment_at = Date.new(2020, 07, 17)
        invoice.end_at = Date.new(2020, 07, 17)
        invoice.save
      end
    end
  end
end
