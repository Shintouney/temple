module ActiveMerchantGatewayMethods
  private

  def gateway
    @gateway ||= ActiveMerchant::Billing::PayboxDirectPlusGateway.new(login: Settings.payment.gateways.paybox.login,
                                                                      password: Settings.payment.gateways.paybox.password)
  end
end
