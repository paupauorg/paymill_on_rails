require 'paymill_on_rails/engine'

module PaymillOnRails

  mattr_accessor :paymill_private_key
  @@paymill_private_key = nil

  mattr_accessor :paymill_public_key
  @@paymill_public_key = nil

  def self.setup
    yield self

    Paymill.api_key = paymill_private_key
  end

end