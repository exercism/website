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
import { useAppTranslation } from '@/i18n/useAppTranslation'

const HEADLINE: Partial<Record<IterationStatus, string>> = {
  actionable_automated_feedback: 'index.suggestionImproveCode',
  celebratory_automated_feedback: 'index.positiveFeedback',
  essential_automated_feedback: 'index.importantSuggestionImproveCode',
  non_actionable_automated_feedback: 'index.thoughtsOnCode',
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
  const { t } = useAppTranslation(
    'components/modals/realtime-feedback-modal/feedback-content/found-automated-feedback'
  )
  const celebratory =
    latestIteration?.status === 'celebratory_automated_feedback'
  return (
    <>
      <div className="flex gap-40 items-start">
        <div className="flex-col items-left">
          <div className="text-h4 mb-16 flex c-iteration-summary">
            {t(HEADLINE[latestIteration!.status] as string)}
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
          text={t(celebratory ? 'index.continue' : 'index.continueAnyway')}
          onClick={onContinue}
          className={!celebratory ? 'btn-secondary' : ''}
        />
      </FooterButtonContainer>
    </>
  )
}
