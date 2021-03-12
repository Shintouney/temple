module HelperMethods
  # Public: Check the presence of a flash message
  # with the given text.
  #
  # i18n_key_or_text -  A I18n key (in the 'flash' namespace)
  #                     or a text String.
  #
  # Returns nothing.
  def assert_flash_presence(i18n_key_or_text)
    flash_text = I18n.t(i18n_key_or_text, scope: 'flash', default: i18n_key_or_text)
    expect(page.find("#flash")).to have_text(flash_text)
  end

  # Public: Log in as the supplied user.
  # Browses to the login page and submits
  # user email and password to the login form.
  #
  # Returns nothing.
  def login_user(user, password)
    visit login_path
    fill_in 'session_email', with: user.email
    fill_in 'session_password', with: password
    find(:css, "input[type='submit']").click
  end

  # Public: Create a user account and log in as this user.
  #
  # user_factory_name - The factory name Symbol to use when creating the User.
  #
  # Returns nothing.
  def login_as(user_factory_name)
    user = FactoryBot.build(user_factory_name)
    login_with(user)
  end

  # Public: Save a user account and log in as this user.
  #
  # user - The User to log in with.
  #
  # Returns nothing.
  def login_with(user)
    password = user.password
    user.save!

    login_user(user, password)
  end

  def fill_in_new_user_form(user_attributes)
    fill_in 'user_email', with: user_attributes[:email]
    fill_in 'user_password', with: user_attributes[:password]
    fill_in 'user_password_confirmation', with: user_attributes[:password_confirmation]
    fill_in 'user_firstname', with: user_attributes[:firstname]
    fill_in 'user_lastname', with: user_attributes[:lastname]
    fill_in 'user_street1', with: user_attributes[:street1]
    fill_in 'user_street2', with: user_attributes[:street2]
    fill_in 'user_postal_code', with: user_attributes[:postal_code]
    fill_in 'user_city', with: user_attributes[:city]
    fill_in 'user_phone', with: user_attributes[:phone]
    fill_in 'user_birthdate', with: I18n.l(user_attributes[:birthdate])
    select User.new(gender: user_attributes[:gender]).gender.text, from: 'user_gender'
  end

  def fill_in_payment_credit_card_form(user_attributes)
    fill_in 'user_credit_card_first_name', with: user_attributes[:firstname]
    fill_in 'user_credit_card_last_name', with: user_attributes[:lastname]
    fill_in 'user_credit_card_number', with: '4242424242424242'
    select 2.months.from_now.month, from: 'user_credit_card_month'
    select 2.years.from_now.year, from: 'user_credit_card_year'
    choose I18n.t('bogus', scope: 'activemerchant.credit_card.brand')
    fill_in 'user_credit_card_verification_value', with: '123'
  end

  def fill_in_credit_card_form
    choose I18n.t('bogus', scope: 'activemerchant.credit_card.brand')
    fill_in 'credit_card_first_name', with: 'Johnny'
    fill_in 'credit_card_last_name', with: 'Donny'
    fill_in 'credit_card_number', with: '1111222233334444'
    select 2.months.from_now.month, from: 'credit_card_month'
    select 2.years.from_now.year, from: 'credit_card_year'
    fill_in 'credit_card_verification_value', with: '123'
    click_button 'credit_card_submit'
  end

  def wait_for_ajax
    max_time = Capybara::Helpers.monotonic_time + Capybara.default_max_wait_time
    while Capybara::Helpers.monotonic_time < max_time
      finished = finished_all_ajax_requests?
      if finished
        break
      else
        sleep 0.1
      end
    end
    raise 'wait_for_ajax timeout' unless finished
  end

  def wait_for_javascript_alerts
    max_time = Capybara::Helpers.monotonic_time + Capybara.default_max_wait_time
    while Capybara::Helpers.monotonic_time < max_time
      finished = has_javascript_alerts?
      if finished
        break
      else
        sleep 0.1
      end
    end
    raise 'wait_for_javascript_alerts timeout' unless finished
  end

  def finished_all_ajax_requests?
  page.evaluate_script(<<~EOS
((typeof window.jQuery === 'undefined')
 || (typeof window.jQuery.active === 'undefined')
 || (window.jQuery.active === 0))
&& ((typeof window.injectedJQueryFromNode === 'undefined')
 || (typeof window.injectedJQueryFromNode.active === 'undefined')
 || (window.injectedJQueryFromNode.active === 0))
&& ((typeof window.httpClients === 'undefined')
 || (window.httpClients.every(function (client) { return (client.activeRequestCount === 0); })))
  EOS
  )
  end

  def has_javascript_alerts?
    page.driver.confirm_messages.length > 0
  end
end

RSpec.configuration.include HelperMethods, type: :feature
