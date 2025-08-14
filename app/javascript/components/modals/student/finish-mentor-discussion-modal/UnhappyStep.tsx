import React from 'react'
import { MentorReport } from '../FinishMentorDiscussionModal'
import { useAppTranslation } from '@/i18n/useAppTranslation'

type Links = {
  exercise: string
}

export const UnhappyStep = ({
  report,
  links,
}: {
  report: MentorReport
  links: Links
}): JSX.Element => {
  const { t } = useAppTranslation(
    'components/modals/student/finish-mentor-discussion-modal'
  )
  return (
    <section className="unhappy-final-step">
      {report.report ? (
        <React.Fragment>
          <h2>{t('unhappyStep.thankYouForReport')}</h2>
          <p className="explanation">{t('unhappyStep.reportExplanation')}</p>
        </React.Fragment>
      ) : report.requeue ? (
        <React.Fragment>
          <h2>{t('unhappyStep.solutionRequeued')}</h2>
          <p className="explanation">{t('unhappyStep.requeueExplanation')}</p>
        </React.Fragment>
      ) : (
        <React.Fragment>
          <h2>{t('unhappyStep.hopeBetterExperience')}</h2>
          <p className="explanation">{t('unhappyStep.sorryExplanation')}</p>
        </React.Fragment>
      )}

      <div className="form-buttons">
        <a href={links.exercise} className="btn-primary btn-m">
          {t('unhappyStep.goToSolution')}
        </a>
      </div>
    </section>
  )
}
