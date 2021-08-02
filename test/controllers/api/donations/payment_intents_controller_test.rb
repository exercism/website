require_relative '../base_test_case'

module API
  class Donations::PaymentIntentsControllerTest < API::BaseTestCase
    ##########
    # Create #
    ##########
    test "create payment intent" do
      user = create :user

      type = 'subscription'
      amount_in_dollars = '12'
      pi_id = SecureRandom.uuid
      pi_client_secret = SecureRandom.uuid

      ::Donations::PaymentIntent::Create.expects(:call).with(
        user, type, amount_in_dollars
      ).returns(OpenStruct.new(id: pi_id, client_secret: pi_client_secret))

      setup_user(user)
      post api_donations_payment_intents_path(
        type: type, amount_in_dollars: amount_in_dollars
      ), headers: @headers, as: :json

      assert_response 200
      assert_equal(
        {
          "payment_intent" => {
            "id" => pi_id,
            "client_secret" => pi_client_secret
          }
        },
        JSON.parse(response.body)
      )
    end

    test "returns an error if raised" do
      error = "oh dear!!"
      ::Donations::PaymentIntent::Create.expects(:call).raises(Stripe::InvalidRequestError.new(error, nil))

      setup_user
      post api_donations_payment_intents_path(
        type: 'subscription', amount_in_dollars: 10
      ), headers: @headers, as: :json

      assert_response 200
      assert_equal(
        {
          "error" => error
        },
        JSON.parse(response.body)
      )
    end

    #############
    # Succeeded #
    #############
    test "handles succeeded" do
      user = create :user

      id = SecureRandom.uuid
      ::Donations::PaymentIntent::HandleSuccess.expects(:call).with(id: id)

      setup_user(user)
      patch succeeded_api_donations_payment_intent_path(id), headers: @headers, as: :json

      assert_response 200
      assert_equal({}.to_json, response.body)
    end
    #############
    # Failed #
    #############
    test "handles failed" do
      user = create :user

      id = SecureRandom.uuid
      ::Donations::PaymentIntent::Cancel.expects(:call).with(id)

      setup_user(user)
      patch failed_api_donations_payment_intent_path(id), headers: @headers, as: :json

      assert_response 200
      assert_equal({}.to_json, response.body)
    end
  end
end
