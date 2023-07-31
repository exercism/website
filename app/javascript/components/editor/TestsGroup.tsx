import React from 'react'
import { Test } from './types'

export type TestWithToggle = Test & { defaultOpen: boolean }

export const TestsGroup = ({
  open = false,
  tests,
  children,
}: {
  open?: boolean
  tests: Test[]
  children: React.ReactNode
}): JSX.Element | null => {
  if (tests.length === 0) {
    return null
  }

  return (
    <details open={open} className="tests-group c-details">
      {children}
    </details>
  )
}

TestsGroup.Header = ({
  children,
}: {
  children: React.ReactNode
}): JSX.Element => (
  <summary className="tests-group-summary">
    <div className="--summary-inner">{children}</div>
  </summary>
)
