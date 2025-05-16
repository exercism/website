import React from 'react'
import { FrontendExercisePageContext } from '../../FrontendExercisePageContext'

export function ActualOutput() {
  const context = React.useContext(FrontendExercisePageContext)
  if (!context) {
    return null
  }
  const { actualIFrameRef } = context

  return (
    <iframe style={{ width: '100%', height: '100%' }} ref={actualIFrameRef} />
  )
}
