import React from 'react'
import { AnalyzerFeedback } from '@/components/student/iterations-list/AnalyzerFeedback'
import { RepresenterFeedback } from '@/components/student/iterations-list/RepresenterFeedback'
import { AnalysisStatusSummary } from '@/components/track/iteration-summary/AnalysisStatusSummary'
import { GoBackToExercise, ContinueButton } from './FeedbackContentButtons'
import { FeedbackContentProps } from '../FeedbackContent'

const HEADLINE = [
  "We've found some automated feedback",
  "We've found a celebratory automated feedback! 🎉",
]

export function FoundAutomatedFeedback({
  latestIteration,
  track,
  automatedFeedbackInfoLink,
  onClose,
  onContinue,
  celebratory = false,
}: Pick<
  FeedbackContentProps,
  'latestIteration' | 'track' | 'automatedFeedbackInfoLink' | 'onClose'
> & { onContinue: () => void; celebratory?: boolean }): JSX.Element {
  return (
    <div className="flex-col items-left">
      <div className="text-h4 mb-16 flex c-iteration-summary">
        {HEADLINE[+celebratory]}
        {latestIteration ? (
          <AnalysisStatusSummary
            numEssentialAutomatedComments={
              latestIteration.numEssentialAutomatedComments
            }
            numActionableAutomatedComments={
              latestIteration.numActionableAutomatedComments
            }
            numNonActionableAutomatedComments={
              latestIteration.numNonActionableAutomatedComments
            }
          />
        ) : null}
      </div>
      {latestIteration?.representerFeedback ? (
        <RepresenterFeedback {...latestIteration.representerFeedback} />
      ) : null}
      {latestIteration?.analyzerFeedback ? (
        <AnalyzerFeedback
          {...latestIteration.analyzerFeedback}
          track={track}
          automatedFeedbackInfoLink={automatedFeedbackInfoLink}
        />
      ) : null}
      <div className="flex gap-16 mt-16">
        {!celebratory && <GoBackToExercise onClick={onClose} />}
        <ContinueButton anyway={!celebratory} onClick={onContinue} />
      </div>
    </div>
  )
}
