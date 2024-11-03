class BootcampController < ApplicationController
  layout "bootcamp"

  skip_before_action :authenticate_user!
  before_action :use_user_bootcamp_data!
  before_action :retrieve_geolocated_data!
  before_action :setup_pricing!

  def index
    if @bootcamp_data # rubocop:disable Style/GuardClause
      @bootcamp_data.num_views += 1
      @bootcamp_data.last_viewed_at = Time.current
      @bootcamp_data.ppp_country = @country_code_2 if @country_code_2 && !@using_vpn
      @bootcamp_data.save
    end
  end

  def start_enrolling
    @name = @bootcamp_data&.name || @bootcamp_data&.user&.name
    @email = @bootcamp_data&.email || @bootcamp_data&.user&.email
    @package = params[:package]

    return unless @bootcamp_data && !@bootcamp_data.enrolled?

    @bootcamp_data.started_enrolling_at = Time.current
    @bootcamp_data.package = @package
    @bootcamp_data.save!
  end

  def do_enrollment
    unless @bootcamp_data
      user = User.create!(
        name: params[:name],
        handle: "bootcamp-#{SecureRandom.hex(8)}",
        email: "bootcamp-#{SecureRandom.hex(8)}@exercism.org",
        password: SecureRandom.hex(8)
      )
      @bootcamp_data = user.create_bootcamp_data!
    end

    @bootcamp_data.update!(
      enrolled_at: Time.current,
      name: params[:name],
      email: params[:email],
      package: params[:package],
      ppp_country: @country_code_2
    )

    redirect_to action: :enrollment_confirmed, package: params[:package]
  end

  def enrollment_confirmed
    @price = params[:package] == "complete" ? @complete_price : @part_1_price
  end

  private
  def use_user_bootcamp_data!
    user_id = cookies.signed[:_exercism_user_id]
    return unless user_id

    user = User.find_by(id: user_id)
    return unless user

    begin
      @bootcamp_data = user.bootcamp_data || user.create_bootcamp_data!
    rescue ActiveRecord::RecordNotUnique
      @bootcamp_data = user.bootcamp_data
    end
  end

  def retrieve_geolocated_data!
    if session[:geolocated_data]
      data = JSON.parse(session[:geolocated_data]).symbolize_keys
      @country_code_2 = data[:country_code_2]
      @using_vpn = data[:is_vpn]
    else
      if Rails.env.production?
        begin
          data = JSON.parse(RestClient.get("https://vpnapi.io/api/#{request.remote_ip}?key=#{Exercism.secrets.vpnapi_key}").body)
          @country_code_2 = data.dig("location", "country_code")
          @using_vpn = data.dig("security", "vpn")
        rescue StandardError
          # Rate limit probably
        end
      else
        @country_code_2 = "IN"
        @using_vpn = false
      end

      session[:geolocated_data] = {
        country_code_2: @country_code_2,
        using_vpn: @using_vpn
      }.to_json
    end
  end

  def setup_pricing!
    country_data = User::BootcampData::DATA[@country_code_2]
    if country_data && !@using_vpn
      @country_name = country_data[0]
      @hello = country_data[1]

      @has_discount = true
      @complete_price = country_data[2].to_f
      @part_1_price = country_data[3].to_f
      @full_payment_url = country_data[4]
      @part_1_payment_url = country_data[5]

      @discount_percentage = (
        (
          User::BootcampData::COMPLETE_PRICE - @complete_price
        ) / User::BootcampData::COMPLETE_PRICE * 100
      ).round
    else
      @has_discount = false
      @complete_price = User::BootcampData::COMPLETE_PRICE
      @part_1_price = User::BootcampData::PART_1_PRICE
      @full_payment_url = User::BootcampData::FULL_PAYMENT_URL
      @part_1_payment_url = User::BootcampData::PART_1_PAYMENT_URL
    end

    @full_complete_price = User::BootcampData::COMPLETE_PRICE
    @full_part_1_price = User::BootcampData::PART_1_PRICE
  end
end

#
# Full: buy.stripe.com/9AQ5logoj1TX52MaEE
# Full with code: ?prefilled_promo_code=XXX
#
#
