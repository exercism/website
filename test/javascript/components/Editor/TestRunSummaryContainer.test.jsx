import React from 'react'
import { render, screen } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { TestRunSummaryContainer } from '../../../../app/javascript/components/editor/TestRunSummaryContainer'
import {
  TestRunStatus,
  TestStatus,
} from '../../../../app/javascript/components/editor/types'

test('hides cancel button if test run has resolved', async () => {
  const { queryByText } = render(
    <TestRunSummaryContainer
      onUpdate={jest.fn()}
      testRun={{
        id: null,
        submissionUuid: '123',
        status: TestRunStatus.PASS,
        message: '',
        tests: [],
        links: {
          self: 'https://exercism.test/test_run',
        },
      }}
    />
  )

  expect(queryByText('Cancel')).not.toBeInTheDocument()
})

test('show header when all tests pass', async () => {
  const { queryByText } = render(
    <TestRunSummaryContainer
      onUpdate={jest.fn()}
      testRun={{
        id: null,
        submissionUuid: '123',
        status: TestRunStatus.PASS,
        message: '',
        tests: [],
        links: {
          self: 'https://exercism.test/test_run',
        },
      }}
    />
  )

  expect(queryByText('All tests passed')).toBeInTheDocument()
})

test('show header when test run fails', async () => {
  const { queryByText } = render(
    <TestRunSummaryContainer
      onUpdate={jest.fn()}
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
        links: {
          self: 'https://exercism.test/test_run',
        },
      }}
    />
  )

  expect(queryByText('Tests failed')).toBeInTheDocument()
  expect(queryByText('All tests passed')).not.toBeInTheDocument()
})

test('shows test failures', async () => {
  render(
    <TestRunSummaryContainer
      onUpdate={jest.fn()}
      testRun={{
        id: null,
        submissionUuid: '123',
        status: TestRunStatus.FAIL,
        messageHtml: 'Unable to run tests',
        tests: [],
        version: 1,
        outputHtml: '',
        links: {
          self: 'https://exercism.test/test_run',
        },
      }}
    />
  )

  expect(screen.getByText('Unable to run tests')).toBeInTheDocument()
})
