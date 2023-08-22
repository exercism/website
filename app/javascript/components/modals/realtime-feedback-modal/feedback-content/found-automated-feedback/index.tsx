import React from 'react'
import { GraphicalIcon } from '@/components/common'
import { AnalyzerFeedback } from './AnalyzerFeedback'
import { RepresenterFeedback } from './RepresenterFeedback'
import {
  GoBackToExercise,
  ContinueButton,
} from '../../components/FeedbackContentButtons'
import { FeedbackContentProps } from '../../FeedbackContent'
import { FooterButtonContainer } from '../../components'
import { IterationStatus } from '@/components/types'

const HEADLINE: Partial<Record<IterationStatus, string>> = {
  actionable_automated_feedback:
    "Here's a suggestion on how to improve your code…",
  celebratory_automated_feedback: 'We have some positive feedback for you! 🎉',
  essential_automated_feedback:
    "Here's an important suggestion on how to improve your code…",
  non_actionable_automated_feedback: 'Here are some thoughts on your code…',
}

export function FoundAutomatedFeedback({
  latestIteration,
  track,
  links,
  onClose,
  onContinue,
}: Pick<
  FeedbackContentProps,
  'latestIteration' | 'track' | 'onClose' | 'links'
> & {
  onContinue: () => void
}): JSX.Element {
  const celebratory =
    latestIteration?.status === 'celebratory_automated_feedback'
  return (
    <>
      <div className="flex gap-40 items-start">
        <div className="flex-col items-left">
          <div className="text-h4 mb-16 flex c-iteration-summary">
            {HEADLINE[latestIteration!.status]}
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

      <FooterButtonContainer>
        {!celebratory && <GoBackToExercise onClick={onClose} />}
        <ContinueButton
          text={celebratory ? 'Continue' : 'Continue anyway'}
          onClick={onContinue}
          className={!celebratory ? 'btn-secondary' : ''}
        />
      </FooterButtonContainer>
    </>
  )
}
