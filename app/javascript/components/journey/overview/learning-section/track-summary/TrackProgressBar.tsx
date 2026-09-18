import React from 'react'
import { Icon } from '../../../../common'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export const TrackProgressBar = ({
  completion,
}: {
  completion: number
}): JSX.Element => {
  const { t } = useAppTranslation(
    'components/journey/overview/learning-section/track-summary/TrackProgressBar.tsx'
  )
  const isComplete = completion === 100
  const classNames = [
    'c-progress',
    '--small',
    isComplete ? '--completed' : '',
  ].filter((className) => className.length > 0)

  return (
    <div className={classNames.join(' ')}>
      <div className="bar" style={{ width: `${completion}%` }} />
      {isComplete ? (
        <div className="completed-icon">
          <Icon
            icon="completed-check-circle"
            alt={t('trackProgressBar.completed')}
            className="completed"
          />
        </div>
      ) : null}
    </div>
  )
}
