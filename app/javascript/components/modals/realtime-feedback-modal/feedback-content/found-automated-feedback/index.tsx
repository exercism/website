import React from 'react'
import { GraphicalIcon } from '@/components/common'
import { AnalyzerFeedback } from './AnalyzerFeedback'
import { RepresenterFeedback } from '@/components/student/iterations-list/RepresenterFeedback'
import { GoBackToExercise, ContinueButton } from '../FeedbackContentButtons'
import { FeedbackContentProps } from '../../FeedbackContent'

const HEADLINE = [
  "Here's a suggestion on how to improve your code…",
  "We've found celebratory automated feedback! 🎉",
]

export function FoundAutomatedFeedback({
  latestIteration,
  track,
  links,
  onClose,
  onContinue,
  celebratory = false,
}: Pick<
  FeedbackContentProps,
  'latestIteration' | 'track' | 'onClose' | 'links'
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
          ) : latestIteration?.analyzerFeedback ? (
            <AnalyzerFeedback
              automatedFeedbackInfoLink={links.automatedFeedbackInfo}
              {...latestIteration.analyzerFeedback}
              track={track}
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
        <ContinueButton
          text={celebratory ? 'Continue' : 'Continue anyway'}
          onClick={onContinue}
          className={!celebratory ? 'btn-secondary' : ''}
        />
      </div>
    </>
  )
}
