// Unsubscribes on the next tick instead of straight away.
//
// React often tears down an effect and runs it again in the same commit: in
// StrictMode on mount, and whenever an effect's dependencies change. If the
// effect subscribes, the client sends subscribe, unsubscribe and subscribe for
// the same identifier. The Rails Action Cable server runs commands on a thread
// pool, so it can run them out of order. It ignores a subscribe for an
// identifier it already has, and it confirms a subscription even if it was
// unsubscribed while setting up. So the client can see a confirmation while the
// server is not streaming, and broadcasts sent then are lost.
//
// Waiting a tick lets the new subscription register on the client first. The
// client then sends no unsubscribe at all, because another subscription still
// uses the identifier, and the server keeps a single subscription.
export function unsubscribeSoon(subscription: ActionCable.Channel): void {
  setTimeout(() => subscription.unsubscribe(), 0)
}
