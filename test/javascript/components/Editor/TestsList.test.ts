import React from 'react'
import { fireEvent, render } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { TestsList } from '../../../../app/javascript/components/editor/TestsList'
import { TestStatus } from '../../../../app/javascript/components/editor/types'

test('shows passed tests', async () => {
  const tests = [
    {
      name: 'first test',
      status: TestStatus.PASS,
    },
    {
      name: 'second test',
      status: TestStatus.PASS,
    },
  ]

  const { getByText, queryByText } = render(<TestsList tests={tests} />)
  fireEvent.click(getByText('2 tests passed'))

  expect(queryByText('first test')).toBeVisible()
  expect(queryByText('second test')).toBeVisible()
})

test('shows number of skipped tests', async () => {
  const tests = [
    {
      name: 'first test',
      status: TestStatus.PASS,
    },
    {
      name: 'second test',
      status: TestStatus.FAIL,
    },
    {
      name: 'third test',
      status: TestStatus.FAIL,
    },
  ]

  const { queryByText } = render(<TestsList tests={tests} />)

  expect(queryByText('1 test skipped')).toBeVisible()
})

test('only shows until first failed test', async () => {
  const tests = [
    {
      name: 'first test',
      status: TestStatus.PASS,
    },
    {
      name: 'second test',
      status: TestStatus.FAIL,
    },
    {
      name: 'third test',
      status: TestStatus.FAIL,
    },
  ]

  const { getByText, queryByText, debug } = render(<TestsList tests={tests} />)
  fireEvent.click(getByText('1 test failed'))

  expect(queryByText('second test')).toBeVisible()
  expect(queryByText('third test')).not.toBeInTheDocument()
})
