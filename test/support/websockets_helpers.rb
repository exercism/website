module WebsocketsHelpers
  # ActionCable has no replay. Anything broadcast before the browser's
  # subscription has been confirmed by the server is dropped on the floor and
  # cannot be recovered by waiting afterwards, so a test that broadcasts too
  # early fails in a way no retry can fix.
  #
  # Use this after visiting a page and *before* broadcasting, in place of
  # sleeping and hoping the subscription got set up in time.
  def wait_for_websocket_subscriptions(count: 1, timeout: Capybara.default_max_wait_time)
    deadline = Process.clock_gettime(Process::CLOCK_MONOTONIC) + timeout

    loop do
      confirmed = confirmed_subscription_count
      return if confirmed >= count

      if Process.clock_gettime(Process::CLOCK_MONOTONIC) > deadline
        raise Capybara::ExpectationNotMet,
          "Expected #{count} confirmed websocket subscription(s), " \
          "got #{confirmed} after #{timeout}s."
      end

      sleep 0.05
    end
  end

  # Gives an already-delivered broadcast a moment to be rendered. Prefer a
  # Capybara assertion (which retries) where one is available - this is only for
  # asserting that something has *not* happened.
  def wait_for_websockets
    sleep(0.5)
  end

  private
  # Mirrors ActionCable's own notion of "confirmed": the connection is open, the
  # subscription is registered, and the guarantor is no longer retrying it
  # (SubscriptionGuarantor#forget runs on confirm_subscription).
  def confirmed_subscription_count
    page.evaluate_script(<<~JS)
      (function() {
        var consumer = window.$$actionCableConsumer
        if (!consumer || !consumer.connection.isOpen()) return 0

        var subscriptions = consumer.subscriptions
        var pending = (subscriptions.guarantor || {}).pendingSubscriptions || []

        return subscriptions.subscriptions.filter(function(subscription) {
          return pending.indexOf(subscription) === -1
        }).length
      })()
    JS
  rescue StandardError
    # The page may not have loaded its JS yet.
    0
  end
end
