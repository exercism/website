class BootcampController < ApplicationController
  layout false
  skip_before_action :authenticate_user!

  COMPLETE_PRICE = 149.99
  PART_1_PRICE = 99.99

  def index
    @full_complete_price = COMPLETE_PRICE
    @full_part_1_price = PART_1_PRICE

    if Rails.env.production?
      begin
        data = JSON.parse(RestClient.get("https://vpnapi.io/api/#{request.remote_ip}?key=#{Exercism.secrets.vpnapi_key}").body)
        @country_code_2 = data.dig("location", "country_code")
        @is_vpn = data.dig("security", "vpn")
      rescue StandardError
        # Rate limit probably
      end
    else
      @country_code_2 = "IN"
      @is_vpn = false
    end

    country_data = DATA[@country_code_2]
    if country_data && !@is_vpn
      @country_name = country_data[0]
      @hello = country_data[1]

      @has_discount = true
      @complete_price = country_data[2].to_f
      @part_1_price = country_data[3].to_f
      @full_payment_url = country_data[4]
      @part_1_payment_url = country_data[5]

      @discount_percentage = ((COMPLETE_PRICE - @complete_price) / COMPLETE_PRICE * 100).round
    else
      @has_discount = false
      @full_payment_link = "https://buy.stripe.com/14k9BE4FBcyBeDmf0f"
      @part_1_payment_link = "https://buy.stripe.com/6oE4hk9ZVfKNeDm7xO"
    end
  end

  DATA = JSON.parse(File.read(Rails.root / 'config' / 'bootcamp.json')).freeze
end

#
# Full: buy.stripe.com/9AQ5logoj1TX52MaEE
# Full with code: ?prefilled_promo_code=XXX
#
#
