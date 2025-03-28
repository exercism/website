import React from 'react'

export function Instructions({
  exerciseTitle,
  exerciseInstructions,
}: {
  exerciseTitle: string
  exerciseInstructions: string
}) {
  return (
    <div className="scenario-rhs c-prose c-prose-small">
      <h3>{exerciseTitle}</h3>

      <div
        dangerouslySetInnerHTML={{
          __html: exerciseInstructions || '<p>Instructions are missing</p>',
        }}
      />
    </div>
  )
}
