import React from 'react'
import { FrontendExercisePageContext } from '../../FrontendExercisePageContext'

export function ExpectedOutput() {
  const context = React.useContext(FrontendExercisePageContext)
  if (!context) {
    return null
  }
  const { expectedIFrameRef } = context

  return (
    <iframe style={{ width: '100%', height: '100%' }} ref={expectedIFrameRef} />
  )
}
