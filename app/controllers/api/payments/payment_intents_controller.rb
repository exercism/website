class API::Payments::PaymentIntentsController < API::BaseController
  before_action :authenticate_user!

  MAX_AMOUNT_IN_CENTS = 99_999_999

  def create
    amount_in_cents = params[:amount_in_cents].to_i
    unless amount_in_cents.between?(1, MAX_AMOUNT_IN_CENTS)
      return render json: { error: "Amount must be between 1 and #{MAX_AMOUNT_IN_CENTS} cents" }, status: :ok
    end

    payment_intent = ::Payments::Stripe::PaymentIntent::Create.(
      current_user || params[:email],
      params[:type],
      params[:amount_in_cents]
    )

    render json: {
      payment_intent: {
        id: payment_intent.id,
        client_secret: payment_intent.client_secret
      }
    }
  rescue Stripe::InvalidRequestError => e
    # React currently can't handle this being
    # anything other than a 200
    render json: {
      error: e.message
    }, status: :ok
  end

  def succeeded
    ::Payments::Stripe::PaymentIntent::HandleSuccess.(id: params[:id])

    render json: {}
  end

  def failed
    ::Payments::Stripe::PaymentIntent::Cancel.(params[:id])

    render json: {}
  end
end
