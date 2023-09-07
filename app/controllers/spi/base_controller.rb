# This is the base controller of Exercism's Secure
# Programmable Interface (SPI).
#
# It is intended to be consumed by internal Exercism
# services and is not avaliable publically.

module SPI
  class BaseController < ApplicationController
    skip_before_action :verify_authenticity_token
    skip_before_action :authenticate_user!
    skip_after_action :set_body_class_header
    skip_after_action :set_csp_header
    skip_after_action :set_link_header

    layout false
  end
end
