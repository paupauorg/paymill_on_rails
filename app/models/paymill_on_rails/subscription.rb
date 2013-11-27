module PaymillOnRails
  class Subscription < ActiveRecord::Base
     
    # paymill_card_token is one-time used token
    # and is not stored into DB, but is used by 
    # Paymill::Payment.create to get payment,
    # then just payment.id is stored 
    # ( see: https://github.com/dkd/paymill-ruby )
    attr_accessor :paymill_card_token, :company

    belongs_to :plan
    belongs_to :user, class_name: ::User
    validates_presence_of :plan_id
    validates_presence_of :email
    accepts_nested_attributes_for :user

    def save_with_payment
      self.email = user.email
      self.name = "#{user.first_name} #{user.last_name}"
      company = ::Company.create(name: self.company)
      self.user.company = company
      if valid?
        company.build_schema
        Apartment::Database.switch company.schema
        ::Import.create_basic_objects
        self.user.role_id = 13
        self.user.company_owner = true
        client = Paymill::Client.create email: email, description: name
        payment = Paymill::Payment.create token: paymill_card_token, client: client.id
        subscription = Paymill::Subscription.create offer: plan.paymill_id, client: client.id, payment: payment.id
        self.paymill_id = subscription.id
        save!
        Apartment::Database.switch
      end
    rescue Paymill::PaymillError => e
      logger.error "Paymill error while creating customer: #{e.message}"
      errors.add :base, "There was a problem with your credit card. Please try again."
      Apartment::Database.switch
      false
    end
  end
end
