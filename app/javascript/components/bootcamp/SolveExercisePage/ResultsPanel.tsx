import React from 'react'
import { TaskPreview } from './TaskPreview/TaskPreview'
import { InspectedTestResultView } from './TestResultsView/InspectedTestResultView'
import useTestStore from './store/testStore'
import { SyntaxErrorView } from './TestResultsView/SyntaxErrorView'
import { UnhandledErrorView } from './TestResultsView/UnhandledErrorView'
import useErrorStore from './store/errorStore'

export function ResultsPanel() {
  const { hasSyntaxError, testSuiteResult } = useTestStore()
  const { hasUnhandledError } = useErrorStore()

  if (hasUnhandledError) {
    return <UnhandledErrorView />
  }

  if (hasSyntaxError) {
    return <SyntaxErrorView />
  }

  return testSuiteResult ? <InspectedTestResultView /> : <TaskPreview />
}
