// i18n-key-prefix: feedbackPanelAutomatedFeedback
// i18n-namespace: components/editor/FeedbackPanel
import React from 'react'
import { AnalyzerFeedback } from '@/components/student/iterations-list/AnalyzerFeedback'
import { RepresenterFeedback } from '@/components/student/iterations-list/RepresenterFeedback'
import { FeedbackDetail } from './FeedbackDetail'
import { FeedbackPanelProps } from './FeedbackPanel'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export function AutomatedFeedback({
  iteration,
  track,
  automatedFeedbackInfoLink,
  open,
}: Pick<
  FeedbackPanelProps,
  'iteration' | 'automatedFeedbackInfoLink' | 'track'
> & { open?: boolean }): JSX.Element | null {
  const { t } = useAppTranslation('components/editor/FeedbackPanel')

  if (
    iteration &&
    (iteration.analyzerFeedback || iteration.representerFeedback)
  ) {
    return (
      <FeedbackDetail
        open={open}
        summary={t('feedbackDetail.automatedFeedback')}
      >
        <>
          {iteration.representerFeedback ? (
            <RepresenterFeedback {...iteration.representerFeedback} />
          ) : null}
          {iteration.representerFeedback && iteration.analyzerFeedback && (
            <hr className="border-t-2 border-borderColor6 my-16" />
          )}
          {iteration.analyzerFeedback ? (
            <AnalyzerFeedback
              {...iteration.analyzerFeedback}
              track={track}
              automatedFeedbackInfoLink={automatedFeedbackInfoLink}
            />
          ) : null}
        </>
      </FeedbackDetail>
    )
  } else return null
}
