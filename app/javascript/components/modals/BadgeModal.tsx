import React from 'react'
import { Badge as BadgeProps } from '../types'
import { GraphicalIcon } from '../common'
import { BadgeMedallion } from '../common/BadgeMedallion'
import { Modal, ModalProps } from './Modal'
import { timeFormat } from '../../utils/time'

export const BadgeModal = ({
  badge,
  wasUnrevealed,
  ...props
}: Omit<ModalProps, 'className'> & {
  badge: BadgeProps
  wasUnrevealed?: boolean
}): JSX.Element => {
  const classNames = ['m-badge', `--${badge.rarity}`, 'theme-dark']

  return (
    <Modal
      {...props}
      closeButton={true}
      className={classNames.join(' ')}
      cover={true}
    >
      <BadgeMedallion badge={badge} />
      {wasUnrevealed ? <h2>New Badge Earned</h2> : null}
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
      <div className="num-awardees text-p-base">
        <GraphicalIcon icon="students" />
        <strong>{badge.numAwardees}</strong> members have earned this badge.
      </div>
      <div className="percentage-awardees">
        That's <strong>{badge.percentageAwardees}%</strong> of all Exercism
        users
      </div>
    </Modal>
  )
}
