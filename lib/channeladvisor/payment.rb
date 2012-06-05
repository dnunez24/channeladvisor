module ChannelAdvisor
  class Payment
    attr_accessor :type, :credit_card_number, :paypal_id, :merchant_reference_number, :transaction_id

    def initialize(attrs={})
      unless attrs.nil?
        @type                       = attrs[:payment_type]
        @credit_card_number         = attrs[:credit_card_last4]  
        @paypal_id                  = attrs[:pay_pal_id]
        @merchant_reference_number  = attrs[:merchant_reference_number]
        @transaction_id             = attrs[:payment_transaction_id]
      end
    end
  end
end