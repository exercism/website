import React from 'react'
import { render } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { TestsStatusSummary } from '../../../../../app/javascript/components/track/iteration-summary/TestsStatusSummary'

test('shows Queued status when testsStatus is queued', async () => {
  const { getByText } = render(<TestsStatusSummary testsStatus="queued" />)

  expect(getByText('Queued')).toBeInTheDocument()
})

test('shows Passed status when testsStatus is passed', async () => {
  const { getByText } = render(<TestsStatusSummary testsStatus="passed" />)

  expect(getByText('Passed')).toBeInTheDocument()
})

test('shows Fail status when testsStatus is failed', async () => {
  const { getByText } = render(<TestsStatusSummary testsStatus="failed" />)

  expect(getByText('Failed')).toBeInTheDocument()
})

test('shows Errored status when testsStatus is error', async () => {
  const { getByText } = render(<TestsStatusSummary testsStatus="errored" />)

  expect(getByText('Errored')).toBeInTheDocument()
})

test('shows Errored status when testsStatus is exceptioned', async () => {
  const { getByText } = render(<TestsStatusSummary testsStatus="exceptioned" />)

  expect(getByText('Errored')).toBeInTheDocument()
})

test('shows Cancelled status when testsStatus is cancelled', async () => {
  const { getByText } = render(<TestsStatusSummary testsStatus="cancelled" />)

  expect(getByText('Cancelled')).toBeInTheDocument()
})
