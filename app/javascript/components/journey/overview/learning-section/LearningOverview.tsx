import pluralize from 'pluralize'
import React from 'react'
import { TrackProgressList } from '../../types'
import { useAppTranslation } from '@/i18n/useAppTranslation'
import { Trans } from 'react-i18next'

export const LearningOverview = ({
  tracks,
}: {
  tracks: TrackProgressList
}): JSX.Element => {
  const { t } = useAppTranslation(
    'components/journey/overview/learning-section'
  )
  return (
    <div className="overview">
      <h3>
        <Trans
          i18nKey={
            tracks.length > 1
              ? 'learningOverview.youReThroughMultiple'
              : 'learningOverview.youReThroughSingle'
          }
          ns="components/journey/overview/learning-section"
          values={{ percentage: tracks.completion.toFixed(2) }}
          components={{
            em: <em className="text-gradient" />,
            strong: tracks.completion > 1 ? <strong /> : <></>,
          }}
        />
      </h3>
      <div className="c-progress --large">
        <div className="bar" style={{ width: `${tracks.completion}%` }} />
      </div>
      <div className="count">
        {t('learningOverview.exercisesCompleted', {
          completed: tracks.numCompletedExercises,
          total: tracks.numExercises,
        })}
      </div>
    </div>
  )
}
