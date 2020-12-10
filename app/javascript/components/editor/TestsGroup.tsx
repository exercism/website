import React from 'react'
import { TestSummary } from './TestSummary'
import { Test } from './types'

export const TestsGroup = ({
  open = false,
  tests,
  children,
}: {
  open?: boolean
  tests: Test[]
  children: React.ReactNode
}): JSX.Element => (
  <details open={open} className="tests-group c-details">
    {children}
    {tests.map((test) => (
      <TestSummary
        key={test.name}
        test={test}
        index={tests.indexOf(test) + 1}
      />
    ))}
  </details>
)

TestsGroup.Header = ({
  children,
}: {
  children: React.ReactNode
}): JSX.Element => <summary className="tests-group-summary">{children}</summary>
