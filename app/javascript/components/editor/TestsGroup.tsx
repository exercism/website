import React, { createContext, useContext } from 'react'
import pluralize from 'pluralize'
import { TestSummary } from './TestSummary'
import { Test } from './types'

export type TestWithToggle = Test & { defaultOpen: boolean }

const TestsGroupContext = createContext<{ tests: TestWithToggle[] }>({
  tests: [],
})

export const TestsGroup = ({
  open = false,
  tests,
  children,
}: {
  open?: boolean
  tests: TestWithToggle[]
  children: React.ReactNode
}): JSX.Element | null => {
  if (tests.length === 0) {
    return null
  }

  return (
    <TestsGroupContext.Provider value={{ tests: tests }}>
      <details open={open} className="tests-group c-details">
        {children}
      </details>
    </TestsGroupContext.Provider>
  )
}

TestsGroup.Header = ({
  children,
}: {
  children: React.ReactNode
}): JSX.Element => <summary className="tests-group-summary">{children}</summary>

TestsGroup.Tests = (): JSX.Element => {
  const { tests } = useContext(TestsGroupContext)

  return (
    <div>
      {tests.map((test) => (
        <TestSummary
          key={test.name}
          test={test}
          defaultOpen={test.defaultOpen}
        />
      ))}
    </div>
  )
}

TestsGroup.Title = ({ status }: { status: string }): JSX.Element => {
  const { tests } = useContext(TestsGroupContext)

  return (
    <>
      {tests.length} {pluralize('test', tests.length)} {status}
    </>
  )
}
