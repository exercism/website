import React from 'react'
import { AnalyzerFeedback } from '@/components/student/iterations-list/AnalyzerFeedback'
import { RepresenterFeedback } from '@/components/student/iterations-list/RepresenterFeedback'
import { FeedbackDetail } from './FeedbackDetail'
import { FeedbackPanelProps } from './FeedbackPanel'

export function AutomatedFeedback({
  iteration,
  track,
  automatedFeedbackInfoLink,
  open,
}: Pick<
  FeedbackPanelProps,
  'iteration' | 'automatedFeedbackInfoLink' | 'track'
> & { open?: boolean }): JSX.Element | null {
  if (
    iteration &&
    (iteration.analyzerFeedback || iteration.representerFeedback)
  ) {
    return (
      <FeedbackDetail open={open} summary="Automated Feedback">
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
