import React, { useContext } from 'react'
import { CSSExercisePageContext } from './CSSExercisePageContext'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export function Instructions() {
  const { t } = useAppTranslation('components/bootcamp/CSSExercisePage')
  const { exercise } = useContext(CSSExercisePageContext)

  return (
    <div className="scenario-rhs c-prose c-prose-small">
      <h3>{exercise.title}</h3>

      <div
        dangerouslySetInnerHTML={{
          __html:
            exercise.introductionHtml ||
            `<p>${t('instructions.missingInstructions')}</p>`,
        }}
      />
    </div>
  )
}
