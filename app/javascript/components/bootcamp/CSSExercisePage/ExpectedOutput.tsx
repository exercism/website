import React from 'react'
import { CSSExercisePageContext } from './CSSExercisePageContext'
export function ExpectedOutput() {
  const context = React.useContext(CSSExercisePageContext)

  if (!context) {
    return null
  }

  const { expectedIFrameRef } = context

  return (
    <div className="p-12">
      <h3 className="mb-8 font-mono font-semibold">Target result</h3>
      <div
        className="css-render-expected"
        style={{
          aspectRatio: context.code.aspectRatio,
        }}
      >
        <iframe
          className="absolute top-0 left-0 h-full w-full"
          ref={expectedIFrameRef}
        />
      </div>
    </div>
  )
}
