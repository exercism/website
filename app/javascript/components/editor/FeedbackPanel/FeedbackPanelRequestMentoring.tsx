// i18n-key-prefix: feedbackPanelRequestMentoring
// i18n-namespace: components/editor/FeedbackPanel
import React from 'react'
import { GraphicalIcon } from '@/components/common'
import { FeedbackPanelProps } from './FeedbackPanel'
import { useAppTranslation } from '@/i18n/useAppTranslation'
import { Trans } from 'react-i18next'

export function RequestMentoring({
  exercise,
  track,
  mentorDiscussionsLink,
}: Pick<
  FeedbackPanelProps,
  'exercise' | 'track' | 'mentorDiscussionsLink'
>): JSX.Element {
  const { t } = useAppTranslation('components/editor/FeedbackPanel')

  return (
    <section className="pt-10">
      <div className="pb-20 mb-20 border-b-1 border-borderColor5">
        <div className="flex items-start">
          <div>
            <h2 className="text-h4 mb-4">
              {t('feedbackPanelRequestMentoring.takeSolutionToNextLevel')}
            </h2>
            <p className="text-p-base mb-16">
              {t('feedbackPanelRequestMentoring.getFeedbackOnSolution', {
                exerciseTitle: exercise.title,
                trackTitle: track.title,
              })}
            </p>
          </div>
          <GraphicalIcon
            icon="mentoring-prompt"
            category="graphics"
            height={110}
            width={110}
            className="ml-48 mt-20"
          />
        </div>
        <div className="flex">
          <a className="btn-primary btn-m mb-8" href={mentorDiscussionsLink}>
            {t('feedbackPanelRequestMentoring.submitForCodeReview')}
          </a>
          <div className="ml-16 px-16 text-midnightBlue bg-lightOrange rounded-8 flex items-center justify-center text-h6 leading-120 h-[48px] text-center">
            {t('feedbackPanelRequestMentoring.free')}
          </div>
        </div>
      </div>

      <h3 className="text-h4 mb-8">
        {t('feedbackPanelRequestMentoring.whyGetFeedback')}
      </h3>
      <div className="mb-12">
        <h4 className="text-h6 mb-4">
          {t('feedbackPanelRequestMentoring.attainRealFluency', {
            trackTitle: track.title,
          })}
        </h4>
        <p className="text-p-base">
          <Trans
            i18nKey="feedbackPanelRequestMentoring.feedbackPanelRequestMentoring.whyGetFeedbackDescription"
            ns="components/editor/FeedbackPanel"
            components={{ bold: <strong className="font-semibold" /> }}
          />
        </p>
      </div>

      <div className="mb-12">
        <h4 className="text-h6 mb-4">
          {t('feedbackPanelRequestMentoring.youDontKnowWhatYouDontKnow')}
        </h4>
        <p className="text-p-base">
          {t('feedbackPanelRequestMentoring.hardToProgress', {
            trackTitle: track.title,
          })}
        </p>
      </div>

      <div className="mb-12">
        <h4 className="text-h6 mb-4">
          {t('feedbackPanelRequestMentoring.getYourQuestionsAnswered')}
        </h4>
        <p className="text-p-base">
          {t('feedbackPanelRequestMentoring.whateverYourQuestions')}
        </p>
      </div>

      <div className="mb-12">
        <h4 className="text-h6 mb-4">
          {t('feedbackPanelRequestMentoring.pushYourself')}
        </h4>
        <p className="text-p-base">
          {t('feedbackPanelRequestMentoring.confidentFeelIn', {
            trackTitle: track.title,
          })}
        </p>
      </div>
    </section>
  )
}
