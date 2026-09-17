import { createConsumer } from '@rails/actioncable'

const consumer = createConsumer()

// Exposed so system tests can wait for a subscription to be confirmed by the
// server before broadcasting. ActionCable has no replay, so anything broadcast
// before the client has subscribed is lost for good - which makes any test that
// sleeps and hopes inherently racy. See test/support/websockets_helpers.rb.
window.$$actionCableConsumer = consumer

export default consumer
