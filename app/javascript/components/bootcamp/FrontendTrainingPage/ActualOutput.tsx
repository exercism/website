import React from 'react'
import { FrontendTrainingPageContext } from './FrontendTrainingPageContext'

export function ActualOutput() {
  const context = React.useContext(FrontendTrainingPageContext)
  if (!context) {
    return null
  }
  const { actualIFrameRef } = context

  return (
    <iframe style={{ width: '100%', height: '100%' }} ref={actualIFrameRef} />
  )
}
