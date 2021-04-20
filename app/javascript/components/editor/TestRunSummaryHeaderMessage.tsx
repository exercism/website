import React from 'react'
import pluralize from 'pluralize'

export const TestRunSummaryHeaderMessage = ({
  version,
  numFailedTests,
}: {
  version: number
  numFailedTests: number
}): JSX.Element => {
  return version === 2 ? (
    <span>
      {numFailedTests} test {pluralize('failure', numFailedTests)}
    </span>
  ) : (
    <span>Tests failed</span>
  )
}
