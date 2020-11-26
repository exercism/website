import React, { useReducer, useEffect, useMemo } from 'react'
import consumer from '../../utils/action-cable-consumer'
import { Icon } from './Icon'

type NotificationIconProps = {
  count: number
}

type NotificationIconAction = {
  type: 'notifications.changed'
  payload: NotificationIconProps
}

function reducer(state: NotificationIconProps, action: NotificationIconAction) {
  switch (action.type) {
    case 'notifications.changed':
      return { count: action.payload.count }
  }
}

export function NotificationIcon({ count }: NotificationIconProps) {
  const [state, dispatch] = useReducer(reducer, { count: count })
  const variantClass = useMemo(() => {
    switch (true) {
      case state.count === 0:
        return '--none'
      case state.count >= 1 && state.count <= 9:
        return '--digital'
      case state.count >= 10 && state.count <= 99:
        return '--double-digit'
      case state.count >= 100:
        return '--triple-digit'
    }
  }, [state.count])

  useEffect(() => {
    const received = (data: NotificationIconAction) => {
      dispatch(data)
    }

    const subscription = consumer.subscriptions.create(
      { channel: 'NotificationsChannel' },
      { received }
    )
    return () => subscription.unsubscribe()
  }, [])

  return (
    <div className={`c-notification ${variantClass}`}>
      <Icon
        icon="notifications"
        alt={`You have ${state.count} notifications`}
      />
      <div className="--count">{state.count}</div>
    </div>
  )
}
