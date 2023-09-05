require_relative '../../test_base'

class Payments::Stripe::Payment::SyncAllTest < Payments::TestBase
  test "reprocesses 'payment_intent.succeeded' events" do
    events = Array.new(5) { create_event }

    first_response = create_response(events.take(3), has_more: true)
    second_response = create_response(events.drop(3), has_more: false)

    stub_request(:get, "https://api.stripe.com/v1/events?limit=100&type=payment_intent.succeeded").
      to_return(status: 200, body: first_response, headers: { 'Content-Type': 'application/json' })

    stub_request(:get, "https://api.stripe.com/v1/events?limit=100&starting_after=#{events[2].id}&type=payment_intent.succeeded").
      to_return(status: 200, body: second_response, headers: { 'Content-Type': 'application/json' })

    events.each do |event|
      Payments::Stripe::HandleEvent.expects(:call).with do |event_arg|
        event_arg.id == event.id
      end
    end

    Payments::Stripe::Payment::SyncAll.()
  end

  test "ignores already processed events" do
    events = Array.new(3) { create_event }
    create :payments_payment, :stripe, external_id: events[1].data.object.id

    response = create_response(events, has_more: false)
    stub_request(:get, "https://api.stripe.com/v1/events?limit=100&type=payment_intent.succeeded").
      to_return(status: 200, body: response, headers: { 'Content-Type': 'application/json' })

    Payments::Stripe::HandleEvent.expects(:call).with { |event| event.id == events[0].id }.once
    Payments::Stripe::HandleEvent.expects(:call).with { |event| event.id == events[2].id }.once
    Payments::Stripe::HandleEvent.expects(:call).with { |event| event.id == events[0].id }.never

    Payments::Stripe::Payment::SyncAll.()
  end

  private
  def create_event
    RecursiveOpenStruct.new({
      id: SecureRandom.uuid,
      object: "event",
      data: {
        object: {
          id: SecureRandom.uuid
        }
      }
    })
  end

  def create_response(events, has_more:)
    {
      object: "list",
      data: events,
      has_more:,
      url: "/v1/events"
    }.to_json
  end
end
