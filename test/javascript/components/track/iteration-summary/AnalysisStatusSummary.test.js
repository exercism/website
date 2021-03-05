import React from 'react'
import { render, screen } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { AnalysisStatusSummary } from '../../../../../app/javascript/components/track/iteration-summary/AnalysisStatusSummary'

test('shows nothing when all zero', async () => {
  render(
    <AnalysisStatusSummary
      numEssentialAutomatedComments={0}
      numActionableAutomatedComments={0}
      numNonActionableAutomatedComments={0}
    />
  )

  expect(
    screen.queryByRole('img', { name: 'Essential automated comments' })
  ).not.toBeInTheDocument()
  expect(
    screen.queryByRole('img', { name: 'Recommended automated comments' })
  ).not.toBeInTheDocument()
  expect(
    screen.queryByRole('img', { name: 'Other automated comments' })
  ).not.toBeInTheDocument()
})

test('shows essential automated comments if they exist', async () => {
  render(<AnalysisStatusSummary numEssentialAutomatedComments={5} />)

  expect(
    screen.getByRole('img', { name: 'Essential automated comments' })
  ).toBeInTheDocument()
  expect(screen.getByText('5')).toBeInTheDocument()
})

test('shows actionable automated comments if they exist', async () => {
  render(<AnalysisStatusSummary numActionableAutomatedComments={4} />)

  expect(
    screen.getByRole('img', { name: 'Recommended automated comments' })
  ).toBeInTheDocument()
  expect(screen.getByText('4')).toBeInTheDocument()
})

test('shows non-actionable utomated comments if they exist', async () => {
  render(<AnalysisStatusSummary numNonActionableAutomatedComments={3} />)

  expect(
    screen.getByRole('img', { name: 'Other automated comments' })
  ).toBeInTheDocument()
  expect(screen.getByText('3')).toBeInTheDocument()
})
