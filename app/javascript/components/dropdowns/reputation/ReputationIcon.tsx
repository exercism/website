import React, { forwardRef } from 'react'
import { Icon } from '../../common/Icon'
import { useAppTranslation } from '@/i18n/useAppTranslation'

type ReputationIconProps = {
  reputation: number
  isSeen: boolean
}

export const ReputationIcon = forwardRef<
  HTMLButtonElement,
  ReputationIconProps
>((props, ref) => {
  const { t } = useAppTranslation('components/dropdowns/reputation')
  const { reputation, isSeen, ...buttonProps } = props

  return (
    <button
      ref={ref}
      className="c-primary-reputation"
      aria-label={t('reputationIcon.reputationAriaLabel', {
        reputation: reputation,
      })}
      {...buttonProps}
    >
      <Icon icon="reputation" alt="Reputation" />
      <span>{reputation}</span>
      <div className={'--notification ' + (isSeen ? '' : 'unseen')} />
    </button>
  )
})
