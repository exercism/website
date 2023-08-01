import React from 'react'
import { GraphicalIcon } from '@/components/common'
import { AnalyzerFeedback } from '@/components/student/iterations-list/AnalyzerFeedback'
import { RepresenterFeedback } from '@/components/student/iterations-list/RepresenterFeedback'
import { AnalysisStatusSummary } from '@/components/track/iteration-summary/AnalysisStatusSummary'
import { GoBackToExercise, ContinueButton } from './FeedbackContentButtons'
import { FeedbackContentProps } from '../FeedbackContent'

const HEADLINE = [
  "Here's a suggestion on how to improve your code…",
  "We've found celebratory automated feedback! 🎉",
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
    <>
      <div className="flex gap-40 items-start">
        <div className="flex-col items-left">
          <div className="text-h4 mb-16 flex c-iteration-summary">
            {HEADLINE[+celebratory]}
          </div>
          {latestIteration?.representerFeedback ? (
            <RepresenterFeedback {...latestIteration.representerFeedback} />
          ) : null}

          {latestIteration?.representerFeedback &&
          latestIteration?.analyzerFeedback ? (
            <hr className="border-t-2 border-borderColor6 mb-12" />
          ) : null}
          {latestIteration?.analyzerFeedback ? (
            <AnalyzerFeedback
              {...latestIteration.analyzerFeedback}
              track={track}
              automatedFeedbackInfoLink={automatedFeedbackInfoLink}
            />
          ) : null}
        </div>
        <GraphicalIcon
          height={160}
          width={160}
          className="mb-16"
          icon="mentoring"
          category="graphics"
        />
      </div>
      <div className="flex gap-16 mt-16">
        {!celebratory && <GoBackToExercise onClick={onClose} />}
        <ContinueButton anyway={!celebratory} onClick={onContinue} />
      </div>
    </>
  )
}
