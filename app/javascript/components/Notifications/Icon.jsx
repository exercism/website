import React, { useReducer, useEffect } from 'react'
import consumer from '../../utils/action-cable-consumer'

function reducer(state, action) {
  switch (action.type) {
    case 'notifications.changed':
      return { count: action.payload.count }
  }
}

export function Icon({ count }) {
  const [state, dispatch] = useReducer(reducer, { count: count })
  const isUnread = state.count > 0

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
      <dd>{isUnread.toString()}</dd>
    </dl>
  )
}
