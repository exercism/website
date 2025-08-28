import React from 'react'
import { useContext } from 'react'
import { FrontendExercisePageContext } from '../../../FrontendExercisePageContext'

export function Instructions() {
  const { exercise } = useContext(FrontendExercisePageContext)

  return (
    <div className="scenario-rhs c-prose c-prose-small">
      <h3>{exercise.title}</h3>

      <div
        dangerouslySetInnerHTML={{
          __html:
            exercise.introductionHtml || '<p>Instructions are missing</p>',
        }}
      />
    </div>
  )
}
