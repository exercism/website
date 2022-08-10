import React from 'react'
import { Badge as BadgeProps } from '../types'
import { GraphicalIcon } from '../common'
import { BadgeMedallion } from '../common/BadgeMedallion'
import { Modal, ModalProps } from './Modal'
import { timeFormat } from '../../utils/time'
import pluralize from 'pluralize'

type BadgeModalProps = Omit<ModalProps, 'className'> & {
  badge: BadgeProps
  wasUnrevealed?: boolean
}

export const BadgeModal = ({
  badge,
  wasUnrevealed,
  ...props
}: BadgeModalProps): JSX.Element => {
  const classNames = ['m-badge', `--${badge.rarity}`, 'theme-dark']

  return (
    <Modal
      {...props}
      closeButton={true}
      className={classNames.join(' ')}
      cover={true}
      aria={{
        describedby: 'a11y-badge-modal-description',
        labelledby: 'a11y-badge-modal-label',
      }}
    >
      <div
        id="a11y-badge-modal-description"
        className="flex flex-col items-center"
      >
        <BadgeMedallion badge={badge} />
        {wasUnrevealed ? <h2>New Badge Earned</h2> : null}
        <div id="a11y-badge-modal-label" className="name">
          {badge.name}
        </div>
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
          <strong>{badge.numAwardees}</strong>{' '}
          {pluralize('member', badge.numAwardees)}{' '}
          {pluralize('has', badge.numAwardees)} earned this badge.
        </div>
        <div className="percentage-awardees">
          That&apos;s <strong>{badge.percentageAwardees}%</strong> of all
          Exercism users
        </div>
      </div>
    </Modal>
  )
}
