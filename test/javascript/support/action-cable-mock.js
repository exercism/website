export function actionCableMock() {
  jest.mock('../../../app/javascript/utils/action-cable-consumer', () => {
    const subscription = {
      unsubscribe: () => null,
    }
    return {
      subscriptions: {
        create: () => subscription,
      },
    }
  })
}
