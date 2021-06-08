import React from 'react'
import { Badge as BadgeProps } from '../types'
import { BadgeMedallion } from './badge-modal/BadgeMedallion'
import { Modal, ModalProps } from './Modal'
import { timeFormat } from '../../utils/time'

export const BadgeModal = ({
  badge,
  ...props
}: Omit<ModalProps, 'className'> & { badge: BadgeProps }): JSX.Element => {
  const classNames = ['m-badge', `--${badge.rarity}`]

  return (
    <Modal {...props} className={classNames.join(' ')} cover={true}>
      <BadgeMedallion badge={badge} />
      <h2>New Badge Earned</h2>
      <div className="name">{badge.name}</div>
      <div className="rarity">{badge.rarity}</div>
      <hr className="c-divider --small" />
      <div className="reason">{badge.description}</div>
      <div className="earned-at">
        Earned on{' '}
        <time dateTime={badge.unlockedAt}>
          {timeFormat(badge.unlockedAt, 'DD MMM YYYY')}
        </time>
      </div>
    </Modal>
  )
}
