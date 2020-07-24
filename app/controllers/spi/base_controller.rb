# This is the base controller of Exercism's Secure
# Programmable Interface (SPI).
#
# It is intended to be consumed by internal Exercism
# services and is not avaliable publically.

module SPI
  class BaseController < ApplicationController
    skip_before_action :verify_authenticity_token

    layout false
  end
end
