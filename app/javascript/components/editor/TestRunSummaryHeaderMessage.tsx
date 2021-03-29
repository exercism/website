import React from 'react'

export const TestRunSummaryHeaderMessage = ({
  version,
}: {
  version: number
}): JSX.Element => {
  return version === 2 ? <span>1 test failure</span> : <span>Tests failed</span>
}
