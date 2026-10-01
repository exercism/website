import React, { useMemo, forwardRef } from 'react'
import { Icon } from '../../common/Icon'
import { useAppTranslation } from '@/i18n/useAppTranslation'

type NotificationsIconProps = {
  count: number
}

export const NotificationsIcon = forwardRef<
  HTMLButtonElement,
  NotificationsIconProps
>((props, ref) => {
  const { t } = useAppTranslation('components/dropdowns/notifications')
  const { count, ...buttonProps } = props
  const variantClass = useMemo(() => {
    switch (true) {
      case count === 0:
        return '--none'
      case count >= 1 && count <= 9:
        return '--single-digit'
      case count >= 10 && count <= 99:
        return '--double-digit'
      case count >= 100:
        return '--triple-digit'
    }
  }, [count])

  return (
    <button
      ref={ref}
      className={`c-notification ${variantClass}`}
      {...buttonProps}
    >
      <Icon
        icon="notifications"
        alt={t('notificationsIcon.youHaveNotifications', { count })}
      />
      <div className="--count">{count}</div>
    </button>
  )
})
