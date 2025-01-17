import React from 'react'
import { TaskPreview } from './TaskPreview/TaskPreview'
import { InspectedTestResultView } from './TestResultsView/InspectedTestResultView'
import useTestStore from './store/testStore'
import { SyntaxErrorView } from './TestResultsView/SyntaxErrorView'
export function ResultsPanel() {
  const { hasSyntaxError } = useTestStore()

  if (hasSyntaxError) {
    return <SyntaxErrorView />
  }

  return (
    <>
      <InspectedTestResultView />
      <TaskPreview />
    </>
  )
}
