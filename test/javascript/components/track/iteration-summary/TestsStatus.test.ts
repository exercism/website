import React from 'react'
import { render } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { TestsStatus } from '../../../../../app/javascript/components/track/iteration-summary/TestsStatus'

test('shows Queued status when testsStatus is queued', async () => {
  const { getByText } = render(<TestsStatus testsStatus="queued" />)

  expect(getByText('Queued')).toBeInTheDocument()
})

test('shows Passed status when testsStatus is passed', async () => {
  const { getByText } = render(<TestsStatus testsStatus="pass" />)

  expect(getByText('Passed')).toBeInTheDocument()
})

test('shows Fail status when testsStatus is failed', async () => {
  const { getByText } = render(<TestsStatus testsStatus="fail" />)

  expect(getByText('Failed')).toBeInTheDocument()
})

test('shows Errored status when testsStatus is error', async () => {
  const { getByText } = render(<TestsStatus testsStatus="error" />)

  expect(getByText('Errored')).toBeInTheDocument()
})

test('shows Errored status when testsStatus is ops error', async () => {
  const { getByText } = render(<TestsStatus testsStatus="ops_error" />)

  expect(getByText('Errored')).toBeInTheDocument()
})

test('shows Cancelled status when testsStatus is cancelled', async () => {
  const { getByText } = render(<TestsStatus testsStatus="cancelled" />)

  expect(getByText('Cancelled')).toBeInTheDocument()
})
