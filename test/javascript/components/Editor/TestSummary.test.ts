import React from 'react'
import { render, fireEvent } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { TestSummary } from '../../../../app/javascript/components/editor/TestSummary'
import { TestStatus } from '../../../../app/javascript/components/editor/types'

test('shows test details', async () => {
  const test = {
    name: 'first test',
    status: TestStatus.PASS,
    output: 'debug',
    message: 'message',
    index: 2,
  }

  const { queryByText } = render(<TestSummary test={test} />)
  fireEvent.click(queryByText('first test'))

  expect(queryByText('Test 2')).toBeVisible()
  expect(queryByText('debug')).toBeVisible()
  expect(queryByText('message')).toBeVisible()
})

test('opens failed tests', async () => {
  const test = {
    name: 'first test',
    status: TestStatus.FAIL,
    output: 'debug',
    message: 'message',
  }

  const { queryByText } = render(<TestSummary test={test} />)

  expect(queryByText('debug')).toBeVisible()
  expect(queryByText('message')).toBeVisible()
})

test('hides output', async () => {
  const test = {
    name: 'first test',
    status: TestStatus.PASS,
    output: '',
  }

  const { queryByText } = render(<TestSummary test={test} />)
  fireEvent.click(queryByText('first test'))

  expect(queryByText('Your Output')).not.toBeInTheDocument()
})

test('hides message', async () => {
  const test = {
    name: 'first test',
    status: TestStatus.PASS,
    output: '',
    message: '',
  }

  const { queryByText } = render(<TestSummary test={test} />)
  fireEvent.click(queryByText('first test'))

  expect(queryByText('Test Error')).not.toBeInTheDocument()
})

test('shows Test Error header for message when tests errored', async () => {
  const test = {
    name: 'first test',
    status: TestStatus.ERROR,
    output: '',
    message: 'Unable to run code',
  }

  const { queryByText } = render(<TestSummary test={test} />)
  fireEvent.click(queryByText('first test'))

  expect(queryByText('Test Error')).toBeInTheDocument()
})

test('shows Test Failure header for message when tests failed', async () => {
  const test = {
    name: 'first test',
    status: TestStatus.FAIL,
    output: '',
    message: 'expected 2',
  }

  const { queryByText } = render(<TestSummary test={test} />)
  fireEvent.click(queryByText('first test'))

  expect(queryByText('Test Failure')).toBeInTheDocument()
})
