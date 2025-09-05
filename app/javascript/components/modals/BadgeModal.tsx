import React from 'react'
import { Badge as BadgeProps } from '../types'
import { GraphicalIcon } from '../common'
import { BadgeMedallion } from '../common/BadgeMedallion'
import { Modal, ModalProps } from './Modal'
import { timeFormat } from '@/utils/time'
import { useAppTranslation } from '@/i18n/useAppTranslation'
import { Trans } from 'react-i18next'

export const BadgeModal = ({
  badge,
  wasUnrevealed,
  ...props
}: Omit<ModalProps, 'className'> & {
  badge: BadgeProps
  wasUnrevealed?: boolean
}): JSX.Element => {
  const { t } = useAppTranslation()
  const classNames = ['m-badge', `--${badge.rarity}`, 'theme-dark']

  return (
    <Modal
      {...props}
      closeButton={true}
      className={classNames.join(' ')}
      cover={true}
    >
      <BadgeMedallion badge={badge} />
      {wasUnrevealed ? <h2>{t('badgeModal.newBadgeEarned')}</h2> : null}
      <div className="name">{badge.name}</div>
      <div className="rarity">{badge.rarity}</div>
      <hr className="c-divider --small" />
      <div className="reason">{badge.description}</div>
      <div className="earned-at">
        {t('badgeModal.earnedOn')}
        <time dateTime={badge.unlockedAt}>
          {timeFormat(badge.unlockedAt, 'Do MMM YYYY')}
        </time>
      </div>
      <div className="num-awardees text-p-base">
        <GraphicalIcon icon="students" />
        <Trans
          values={{ count: badge.numAwardees }}
          i18nKey="badgeModal.membersHaveEarned"
          components={[<strong />]}
        />
      </div>
      <div className="percentage-awardees">
        {t('badgeModal.percentageOfUsers', {
          percentage: badge.percentageAwardees,
        })}
      </div>
    </Modal>
  )
}
