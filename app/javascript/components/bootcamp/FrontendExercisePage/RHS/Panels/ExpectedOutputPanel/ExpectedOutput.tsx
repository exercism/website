import React from 'react'
import { FrontendExercisePageContext } from '../../../FrontendExercisePageContext'

export function ExpectedOutput() {
  const context = React.useContext(FrontendExercisePageContext)
  if (!context) {
    return null
  }
  const { expectedIFrameRef } = context

  return (
    <div className="fe-render-expected">
      <iframe
        className="absolute top-0 left-0 h-full w-full"
        ref={expectedIFrameRef}
      />
    </div>
  )
}
