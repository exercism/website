import React from 'react'
import { useContext } from 'react'
import { FrontendExercisePageContext } from '../../../FrontendExercisePageContext'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export function Instructions() {
  const { t } = useAppTranslation(
    'components/bootcamp/FrontendExercisePage/RHS'
  )
  const { exercise } = useContext(FrontendExercisePageContext)

  return (
    <div className="scenario-rhs c-prose c-prose-small">
      <h3>{exercise.title}</h3>

      <div
        dangerouslySetInnerHTML={{
          __html:
            exercise.introductionHtml ||
            t('panels.instructionsPanel.instructions.instructionsAreMissing'),
        }}
      />
    </div>
  )
}
