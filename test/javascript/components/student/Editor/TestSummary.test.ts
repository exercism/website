import React from 'react'
import { render, fireEvent } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { TestSummary } from '../../../../../app/javascript/components/student/editor/TestSummary'
import { TestStatus } from '../../../../../app/javascript/components/student/editor/TestRunSummary'

test('shows test details', async () => {
  const test = {
    name: 'first test',
    status: TestStatus.PASS,
    output: 'debug',
    message: 'message',
  }

  const { queryByText } = render(<TestSummary test={test} />)
  fireEvent.click(queryByText('Passed: first test'))

  expect(queryByText('Output: debug')).toBeVisible()
  expect(queryByText('Message: message')).toBeVisible()
})

test('opens failed tests', async () => {
  const test = {
    name: 'first test',
    status: TestStatus.FAIL,
    output: 'debug',
    message: 'message',
  }

  const { queryByText } = render(<TestSummary test={test} />)

  expect(queryByText('Output: debug')).toBeVisible()
  expect(queryByText('Message: message')).toBeVisible()
})

test('hides output', async () => {
  const test = {
    name: 'first test',
    status: TestStatus.PASS,
    output: '',
  }

  const { queryByText } = render(<TestSummary test={test} />)
  fireEvent.click(queryByText('Passed: first test'))

  expect(queryByText('Output:')).not.toBeInTheDocument()
})

test('hides message', async () => {
  const test = {
    name: 'first test',
    status: TestStatus.PASS,
    output: '',
    message: '',
  }

  const { queryByText } = render(<TestSummary test={test} />)
  fireEvent.click(queryByText('Passed: first test'))

  expect(queryByText('Message:')).not.toBeInTheDocument()
})
