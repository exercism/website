import React, { useReducer, useEffect } from 'react'
import consumer from '../../application/action_cable_consumer'

function reducer(state, action) {
  switch (action.type) {
    case 'notification.created':
      return { count: state.count + 1, unread: true }
  }
}

export function NotificationIcon({ count, unread }) {
  const [state, dispatch] = useReducer(reducer, {
    count: count,
    unread: unread,
  })

  useEffect(() => {
    const received = (data) => {
      dispatch(data)
    }

    const subscription = consumer.subscriptions.create(
      { channel: 'NotificationsChannel' },
      { received }
    )
    return () => subscription.unsubscribe()
  }, [])

  return (
    <dl>
      <dt>Count</dt>
      <dd>{state.count}</dd>
      <dt>Unread</dt>
      <dd>{state.unread.toString()}</dd>
    </dl>
  )
}
