import React, { createContext, useContext } from 'react'
import pluralize from 'pluralize'
import { TestSummary } from './TestSummary'
import { Test } from './types'

export type TestWithToggle = Test & { defaultOpen: boolean }

const TestsGroupContext = createContext<{
  tests: TestWithToggle[]
  language: string
}>({
  tests: [],
  language: '',
})

export const TestsGroup = ({
  open = false,
  tests,
  language,
  children,
}: {
  open?: boolean
  tests: TestWithToggle[]
  language: string
  children: React.ReactNode
}): JSX.Element | null => {
  if (tests.length === 0) {
    return null
  }

  return (
    <TestsGroupContext.Provider value={{ tests: tests, language: language }}>
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
}): JSX.Element => (
  <summary className="tests-group-summary">
    <div className="--summary-inner">{children}</div>
  </summary>
)

TestsGroup.Tests = (): JSX.Element => {
  const { tests, language } = useContext(TestsGroupContext)

  return (
    <>
      {tests.map((test) => (
        <TestSummary
          key={test.name}
          test={test}
          defaultOpen={test.defaultOpen}
          language={language}
        />
      ))}
    </>
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
