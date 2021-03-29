import React from 'react'
import { render, screen } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import userEvent from '@testing-library/user-event'
import { TestsGroupList } from '../../../../app/javascript/components/editor/TestsGroupList'
import { TestStatus } from '../../../../app/javascript/components/editor/types'

test('shows passed tests', async () => {
  const tests = [
    {
      name: 'first test',
      status: TestStatus.PASS,
      testCode: '',
      message: '',
      output: '',
    },
    {
      name: 'second test',
      status: TestStatus.PASS,
      testCode: '',
      message: '',
      output: '',
    },
  ]

  render(<TestsGroupList tests={tests} />)
  userEvent.click(screen.getByText('2 tests passed'))

  expect(screen.getByText('first test')).toBeInTheDocument()
  expect(screen.getByText('second test')).toBeInTheDocument()
})

test('shows number of skipped tests', async () => {
  const tests = [
    {
      name: 'first test',
      status: TestStatus.PASS,
      testCode: '',
      message: '',
      output: '',
    },
    {
      name: 'second test',
      status: TestStatus.FAIL,
      testCode: '',
      message: '',
      output: '',
    },
    {
      name: 'third test',
      status: TestStatus.FAIL,
      testCode: '',
      message: '',
      output: '',
    },
  ]

  render(<TestsGroupList tests={tests} />)

  expect(screen.getByText('1 test skipped')).toBeInTheDocument()
})

test('only shows until first failed test', async () => {
  const tests = [
    {
      name: 'first test',
      status: TestStatus.PASS,
      testCode: '',
      message: '',
      output: '',
    },
    {
      name: 'second test',
      status: TestStatus.FAIL,
      testCode: '',
      message: '',
      output: '',
    },
    {
      name: 'third test',
      status: TestStatus.FAIL,
      testCode: '',
      message: '',
      output: '',
    },
  ]

  render(<TestsGroupList tests={tests} />)

  expect(screen.getByText('second test')).toBeInTheDocument()
  expect(screen.queryByText('third test')).not.toBeInTheDocument()
})
