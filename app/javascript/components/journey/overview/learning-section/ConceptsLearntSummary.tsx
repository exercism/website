import React from 'react'
import { TrackProgressList } from '../../types'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export const ConceptsLearntSummary = ({
  tracks,
}: {
  tracks: TrackProgressList
}): JSX.Element => {
  const { t } = useAppTranslation(
    'components/journey/overview/learning-section'
  )

  return (
    <div className="box">
      <div className="journey-h3">{tracks.numConceptsLearnt}</div>
      <div className="journey-label">
        {t(
          tracks.numConceptsLearnt > 1
            ? 'conceptsLearntSummary.conceptsLearnt'
            : 'conceptsLearntSummary.conceptLearnt',
          {
            count: tracks.numConceptsLearnt,
          }
        )}{' '}
      </div>
    </div>
  )
}
