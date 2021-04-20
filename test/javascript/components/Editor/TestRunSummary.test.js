import React from 'react'
import { render, screen } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { TestRunSummary } from '../../../../app/javascript/components/editor/TestRunSummary'
import {
  TestRunStatus,
  TestStatus,
} from '../../../../app/javascript/components/editor/types'

test('hides cancel button if test run has resolved', async () => {
  const { queryByText } = render(
    <TestRunSummary
      testRun={{
        id: null,
        submissionUuid: '123',
        status: TestRunStatus.PASS,
        message: '',
        tests: [],
      }}
    />
  )

  expect(queryByText('Cancel')).not.toBeInTheDocument()
})

test('show header when all tests pass', async () => {
  const { queryByText } = render(
    <TestRunSummary
      testRun={{
        id: null,
        submissionUuid: '123',
        status: TestRunStatus.PASS,
        message: '',
        tests: [],
      }}
    />
  )

  expect(queryByText('All tests passed')).toBeInTheDocument()
})

test('show header when test run fails', async () => {
  const { queryByText } = render(
    <TestRunSummary
      testRun={{
        id: null,
        submissionUuid: '123',
        status: TestRunStatus.FAIL,
        message: '',
        tests: [
          {
            name: 'test 1',
            status: TestStatus.FAIL,
          },
          {
            name: 'test 2',
            status: TestStatus.FAIL,
          },
        ],
      }}
    />
  )

  expect(queryByText('Tests failed')).toBeInTheDocument()
  expect(queryByText('All tests passed')).not.toBeInTheDocument()
})

test('shows test failures', async () => {
  render(
    <TestRunSummary
      testRun={{
        id: null,
        submissionUuid: '123',
        status: TestRunStatus.FAIL,
        message: '',
        tests: [],
        version: 1,
        outputHtml: 'Unable to run tests',
      }}
    />
  )

  expect(screen.getByText('Unable to run tests')).toBeInTheDocument()
})
