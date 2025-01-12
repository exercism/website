class BootcampController < ApplicationController
  layout 'bootcamp'

  skip_before_action :authenticate_user!
  before_action :redirect_if_paid!
  before_action :save_utm!
  before_action :setup_data!
  before_action :setup_pricing!

  def index
    if @bootcamp_data
      @bootcamp_data.num_views += 1
      @bootcamp_data.last_viewed_at = Time.current
      @bootcamp_data.ppp_country = @country_code_2 if @country_code_2
      @bootcamp_data.save
    end

    difference_in_seconds = Time.utc(2025, 1, 11, 18, 0, 0) - Time.current

    # Convert to days, hours, minutes, and seconds
    @days = (difference_in_seconds / (24 * 60 * 60)).to_i
    @hours = (difference_in_seconds % (24 * 60 * 60) / (60 * 60)).to_i
    @minutes = (difference_in_seconds % (60 * 60) / 60).to_i
    @seconds = (difference_in_seconds % 60).to_i
  end

  def start_enrolling
    create_bootcamp_data!

    @name = @bootcamp_data.name || @bootcamp_data&.user&.name
    @email = @bootcamp_data.email || @bootcamp_data&.user&.email
    @package = params[:package] || @bootcamp_data.package

    unless @bootcamp_data.enrolled? # rubocop:disable Style/GuardClause
      @bootcamp_data.started_enrolling_at = Time.current
      @bootcamp_data.package = @package if params[:package].present?
      @bootcamp_data.save!
    end
  end

  def do_enrollment
    create_bootcamp_data!

    @bootcamp_data.update!(
      enrolled_at: Time.current,
      name: params[:name],
      email: params[:email],
      package: params[:package],
      ppp_country: @country_code_2
    )

    redirect_to action: :pay
  end

  def pay
    redirect_to action: :start_enrolling unless @bootcamp_data&.enrolled?
  end

  def stripe_create_checkout_session
    if Rails.env.production?
      stripe_price = @bootcamp_data.stripe_price_id
    else
      stripe_price = "price_1QCjUFEoOT0Jqx0UJOkhigru"
    end

    session = Stripe::Checkout::Session.create({
      ui_mode: 'embedded',
      customer_email: @bootcamp_data.email,
      customer_creation: "always",
      line_items: [{
        price: stripe_price,
        quantity: 1
      }],
      mode: 'payment',
      allow_promotion_codes: true,
      return_url: "#{bootcamp_confirmed_url}?session_id={CHECKOUT_SESSION_ID}"
    })

    render json: { clientSecret: session.client_secret }
  end

  def stripe_session_status
    session = Stripe::Checkout::Session.retrieve(params[:session_id])

    if session.status == 'complete'
      @bootcamp_data.update!(
        paid_at: Time.current,
        checkout_session_id: session.id,
        access_code: SecureRandom.hex(8)
      )
      if current_user
        User::BecomeBootcampAttendee.(current_user)
      else
        user = User.find_by(email: @bootcamp_data.email)
        if user
          # Reset old bootcamp data sessions
          User::BootcampData.where(user:).
            where.not(id: @bootcamp_data.id).
            update_all(user_id: nil)

          # Enroll this one.
          @bootcamp_data.update(user:)
          User::BecomeBootcampAttendee.(user)
        end
      end
    end

    render json: {
      status: session.status,
      customer_email: session.customer_details.email
    }
  end

  def confirmed; end

  private
  def setup_data!
    @bootcamp_data = retrieve_user_bootcamp_data_from_user
    @bootcamp_data ||= retrieve_user_bootcamp_data_from_session

    if @bootcamp_data && @bootcamp_data.ppp_country.present?
      session[:bootcamp_data_id] = @bootcamp_data.id
      @country_code_2 = @bootcamp_data.ppp_country
    elsif session[:country_code_2].present?
      @country_code_2 = session[:country_code_2]
    else
      @country_code_2 = lookup_country_code_from_ip
      session[:country_code_2] = @country_code_2
    end

    # rubocop:disable Style/SafeNavigation
    if @bootcamp_data && @bootcamp_data.user_id&.nil? && cookies.signed[:_exercism_user_id].present? # rubocop:disable Style/GuardClause
      @bootcamp_data.update(user_id: cookies.signed[:_exercism_user_id])
    end
    # rubocop:enable Style/SafeNavigation
  end

  def retrieve_user_bootcamp_data_from_user
    user_id = cookies.signed[:_exercism_user_id]
    return unless user_id

    user = User.find_by(id: user_id)
    return unless user

    begin
      user.bootcamp_data || user.create_bootcamp_data!
    rescue ActiveRecord::RecordNotUnique
      # Guard the race condition
      user.bootcamp_data
    end
  rescue StandardError
    # Something's a mess, but don't blow up.
  end

  def retrieve_user_bootcamp_data_from_session
    return unless session[:bootcamp_data_id].present?

    User::BootcampData.find(session[:bootcamp_data_id])
  rescue StandardError
    # We don't have anything valid in the session.
  end

  def lookup_country_code_from_ip
    return "MX" unless Rails.env.production?

    data = JSON.parse(RestClient.get("https://vpnapi.io/api/#{request.remote_ip}?key=#{Exercism.secrets.vpnapi_key}").body)
    return "VPN" if data.dig("security", "vpn")

    data.dig("location", "country_code")
  rescue StandardError
    # Rate limit probably
  end

  def create_bootcamp_data!
    return if @bootcamp_data

    @bootcamp_data = User::BootcampData.create!(ppp_country: @country_code_2, utm: session[:utm])
    session[:bootcamp_data_id] = @bootcamp_data.id

    return unless cookies.signed[:_exercism_user_id].present? && @bootcamp_data.user_id.nil?

    @bootcamp_data.update(user_id: cookies.signed[:_exercism_user_id])
  end

  def setup_pricing!
    country_data = User::BootcampData::DATA[@country_code_2]
    if country_data
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

  def save_utm!
    session[:utm] ||= {}
    session[:utm][:source] = params[:utm_source] if params[:utm_source].present?
    session[:utm][:medium] = params[:utm_medium] if params[:utm_medium].present?
    session[:utm][:campaign] = params[:utm_campaign] if params[:utm_campaign].present?
  end

  def redirect_if_paid!
    return unless current_user&.bootcamp_attendee? || current_user&.bootcamp_mentor?

    redirect_to bootcamp_dashboard_url
  end
end
