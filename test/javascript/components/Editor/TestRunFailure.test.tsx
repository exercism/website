import React from 'react'
import { screen, render } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { TestRunFailure } from '../../../../app/javascript/components/editor/TestRunFailure'
import {
  TestRun,
  TestRunStatus,
  TestStatus,
} from '../../../../app/javascript/components/editor/types'

test('shows test run output for version 1 test runner', async () => {
  const testRun: TestRun = {
    id: null,
    submissionUuid: '123',
    status: TestRunStatus.FAIL,
    message: '',
    tests: [],
    version: 1,
    output: 'Unable to run tests',
  }

  render(<TestRunFailure testRun={testRun} />)

  expect(screen.getByText('Unable to run tests')).toBeInTheDocument()
})

test('shows tests for version 2 test runner', async () => {
  const testRun: TestRun = {
    id: null,
    submissionUuid: '123',
    status: TestRunStatus.FAIL,
    message: '',
    tests: [
      {
        name: 'equal to 1',
        status: TestStatus.FAIL,
        testCode: '212',
        message: 'Failed test',
        output: '',
      },
    ],
    version: 2,
    output: '',
  }

  render(<TestRunFailure testRun={testRun} />)

  expect(screen.getByText('equal to 1')).toBeInTheDocument()
})
