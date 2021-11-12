import React from 'react'
import { render, fireEvent } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { TestSummary } from '../../../../app/javascript/components/editor/TestSummary'
import { TestStatus } from '../../../../app/javascript/components/editor/types'

test('shows test details', async () => {
  const test = {
    name: 'first test',
    status: TestStatus.PASS,
    testCode: 'assert(false, Year.isLeap())',
    output: 'debug',
    outputHtml: 'debug',
    message: 'message',
    messageHtml: 'message',
    index: 2,
  }

  const { queryByText } = render(<TestSummary test={test} />)
  fireEvent.click(queryByText('first test'))

  expect(queryByText('Test 2')).toBeVisible()
  expect(queryByText('debug')).toBeVisible()
  expect(queryByText('message')).toBeVisible()
})

test('hides output', async () => {
  const test = {
    name: 'first test',
    status: TestStatus.PASS,
    testCode: '',
    message: '',
    messageHtml: '',
    output: '',
    outputHtml: '',
  }

  const { queryByText } = render(<TestSummary test={test} />)
  fireEvent.click(queryByText('first test'))

  expect(queryByText('Your Output')).not.toBeInTheDocument()
})

test('hides message', async () => {
  const test = {
    name: 'first test',
    status: TestStatus.PASS,
    testCode: '',
    output: '',
    outputHtml: '',
    message: '',
    messageHtml: '',
  }

  const { queryByText } = render(<TestSummary test={test} />)
  fireEvent.click(queryByText('first test'))

  expect(queryByText('Test Error')).not.toBeInTheDocument()
})

test('shows Test Error header for message when tests errored', async () => {
  const test = {
    name: 'first test',
    status: TestStatus.ERROR,
    testCode: '',
    output: '',
    outputHtml: '',
    message: 'Unable to run code',
    messageHtml: 'Unable to run code',
  }

  const { queryByText } = render(<TestSummary test={test} />)
  fireEvent.click(queryByText('first test'))

  expect(queryByText('Test Error')).toBeInTheDocument()
})

test('shows Test Failure header for message when tests failed', async () => {
  const test = {
    name: 'first test',
    status: TestStatus.FAIL,
    testCode: '',
    output: '',
    outputHtml: '',
    message: 'expected 2',
    messageHtml: 'expected 2',
  }

  const { queryByText } = render(<TestSummary test={test} />)
  fireEvent.click(queryByText('first test'))

  expect(queryByText('Test Failure')).toBeInTheDocument()
})
