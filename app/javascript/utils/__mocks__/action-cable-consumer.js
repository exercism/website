const createConsumer = function () {
  const subscription = {
    unsubscribe: () => null,
  }
  return {
    subscriptions: {
      create: () => subscription,
    },
  }
}
export default createConsumer()
