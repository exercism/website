import React from 'react'
import { Trans } from 'react-i18next'
import { TrackProgressList } from '../../types'
import { useAppTranslation } from '@/i18n/useAppTranslation'

type Links = {
  solutions: string
  fable: string
}

export const LearningStats = ({
  tracks,
  links,
}: {
  tracks: TrackProgressList
  links: Links
}): JSX.Element => {
  const { t } = useAppTranslation(
    'components/journey/overview/learning-section'
  )

  return (
    <div className="stats">
      <h3>{t('learningStats.didYouKnow')}</h3>

      <div className="stat">
        <Trans
          i18nKey="learningStats.linesOfCodeStat"
          ns="components/journey/overview/learning-section"
          values={{
            // Pre-formatted so each count pluralises under its own rules.
            lines: t('learningStats.lineCount', {
              count: tracks.numLines,
              formattedCount: tracks.numLines.toLocaleString(),
            }),
            solutions: t('learningStats.solutionCount', {
              count: tracks.numSolutions,
            }),
          }}
          components={{
            strong: <strong />,
            link: <a href={links.solutions} />,
          }}
        />
      </div>

      <div className="stat">
        <Trans
          i18nKey="learningStats.aesopFact"
          ns="components/journey/overview/learning-section"
          components={{
            fableLink: <a href={links.fable} />,
          }}
        />
      </div>
    </div>
  )
}
