import React, { useContext } from 'react'
import { CSSExercisePageContext } from './CSSExercisePageContext'

export function Instructions() {
  const { exercise } = useContext(CSSExercisePageContext)

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
