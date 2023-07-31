import React from 'react'
import pluralize from 'pluralize'

export const TestRunSummaryByStatusHeaderMessage = ({
  version,
  numFailedTests,
}: {
  version: number
  numFailedTests: number
}): JSX.Element => {
  return version === 2 || version === 3 ? (
    <span>
      {numFailedTests} test {pluralize('failure', numFailedTests)}
    </span>
  ) : (
    <span>Tests failed</span>
  )
}
