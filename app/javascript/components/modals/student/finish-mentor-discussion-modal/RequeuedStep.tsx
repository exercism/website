import React from 'react'
import { useAppTranslation } from '@/i18n/useAppTranslation'

type Links = {
  exercise: string
}

export const RequeuedStep = ({ links }: { links: Links }): JSX.Element => {
  const { t } = useAppTranslation(
    'components/modals/student/finish-mentor-discussion-modal'
  )
  return (
    <section className="acceptable-final-step">
      <h2>{t('requeuedStep.solutionRequeued')}</h2>
      <p className="explanation">{t('requeuedStep.requedExplanation')}</p>

      <div className="form-buttons">
        <a href={links.exercise} className="btn-primary btn-m">
          {t('requeuedStep.goToSolution')}
        </a>
      </div>
    </section>
  )
}
