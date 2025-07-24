// i18n-key-prefix: analysisInformation
// i18n-namespace: components/student/iterations-list
import React from 'react'
import { GraphicalIcon } from '../../common'
import { Iteration, IterationStatus } from '../../types'
import { Exercise, Track, Links } from '../IterationsList'
import { RepresenterFeedback } from './RepresenterFeedback'
import { AnalyzerFeedback } from './AnalyzerFeedback'
import { useAppTranslation } from '@/i18n/useAppTranslation'
import { Trans } from 'react-i18next'

export const AnalysisInformation = ({
  iteration,
  exercise,
  track,
  links,
}: {
  iteration: Iteration
  exercise: Exercise
  track: Track
  links: Links
}): JSX.Element | null => {
  const { t } = useAppTranslation('components/student/iterations-list')

  switch (iteration.status) {
    case IterationStatus.DELETED:
    case IterationStatus.TESTING:
    case IterationStatus.ANALYZING:
      return (
        <div className="automated-feedback-pending">
          <GraphicalIcon icon="spinner" className="animate-spin-slow" />
          <h3>{t('analysisInformation.analyzingCode')}</h3>
          <p>{t('analysisInformation.analysisTime')}</p>
        </div>
      )
    case IterationStatus.UNTESTED:
    case IterationStatus.NO_AUTOMATED_FEEDBACK:
      return (
        <div className="automated-feedback-absent">
          <GraphicalIcon icon="mentoring" category="graphics" />
          <h3>{t('analysisInformation.noAutoSuggestions')}</h3>
          <p>
            {t('analysisInformation.getHumanMentoring', {
              exerciseTitle: exercise.title,
              trackTitle: track.title,
            })}
          </p>
          <a href={links.getMentoring} className="btn-secondary btn-m">
            {t('analysisInformation.getMentoring')}
          </a>
        </div>
      )
    case IterationStatus.TESTS_FAILED:
      return (
        <div className="automated-feedback-absent">
          <GraphicalIcon icon="tests-failed" category="graphics" />
          <h3>{t('analysisInformation.testFailed')}</h3>
          <p>{t('analysisInformation.passingTestsNeeded')}</p>
          <div className="upsell">
            <Trans
              ns="components/student/iterations-list"
              i18nKey="analysisInformation.interestedInImprovingTooling"
              components={{
                helpLink: <a href={links.toolingHelp} />,
              }}
            />
          </div>
        </div>
      )
    default: {
      return (
        <React.Fragment>
          {iteration.representerFeedback ? (
            <RepresenterFeedback {...iteration.representerFeedback} />
          ) : null}
          {iteration.analyzerFeedback ? (
            <AnalyzerFeedback
              {...iteration.analyzerFeedback}
              track={track}
              automatedFeedbackInfoLink={links.automatedFeedbackInfo}
            />
          ) : null}
        </React.Fragment>
      )
    }
  }
}
