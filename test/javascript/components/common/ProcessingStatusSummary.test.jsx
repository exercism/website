import React from 'react'
import { render, screen } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { ProcessingStatusSummary } from '../../../../app/javascript/components/common/ProcessingStatusSummary'

test('shows Processing status when iterationStatus is analyzing', async () => {
  render(<ProcessingStatusSummary iterationStatus="analyzing" />)

  expect(
    screen.getByRole('status', { name: 'Processing status' })
  ).toHaveAttribute('class', 'c-iteration-processing-status --processing')
  expect(screen.getByText('Processing')).toBeInTheDocument()
})

test('shows Processing status when iterationStatus is testing', async () => {
  render(<ProcessingStatusSummary iterationStatus="testing" />)

  expect(
    screen.getByRole('status', { name: 'Processing status' })
  ).toHaveAttribute('class', 'c-iteration-processing-status --processing')
  expect(screen.getByText('Processing')).toBeInTheDocument()
})

test('shows Failed status when iterationStatus is failed', async () => {
  render(<ProcessingStatusSummary iterationStatus="tests_failed" />)

  expect(
    screen.getByRole('status', { name: 'Processing status' })
  ).toHaveAttribute('class', 'c-iteration-processing-status --failed')
  expect(screen.getByText('Failed')).toBeInTheDocument()
})

test('shows Passed status when iterationStatus is another status', async () => {
  render(<ProcessingStatusSummary iterationStatus="no_automated_feedback" />)

  expect(
    screen.getByRole('status', { name: 'Processing status' })
  ).toHaveAttribute('class', 'c-iteration-processing-status --passed')
  expect(screen.getByText('Passed')).toBeInTheDocument()
})
