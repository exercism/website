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
    screen.queryByRole('img', { name: 'Automated comments' })
  ).not.toBeInTheDocument()
  expect(screen.queryByTitle('Essential')).not.toBeInTheDocument()
  expect(screen.queryByTitle('Actionable')).not.toBeInTheDocument()
  expect(screen.queryByTitle('Other')).not.toBeInTheDocument()
})

test('shows essential automated comments if they exist', async () => {
  render(<AnalysisStatusSummary numEssentialAutomatedComments={5} />)

  expect(
    screen.getByRole('img', { name: 'Automated comments' })
  ).toBeInTheDocument()
  expect(screen.getByTitle('Essential')).toBeInTheDocument()
  expect(screen.getByText('5')).toBeInTheDocument()
})

test('shows actionable automated comments if they exist', async () => {
  render(<AnalysisStatusSummary numActionableAutomatedComments={4} />)

  expect(
    screen.getByRole('img', { name: 'Automated comments' })
  ).toBeInTheDocument()
  expect(screen.getByTitle('Actionable')).toBeInTheDocument()
  expect(screen.getByText('4')).toBeInTheDocument()
})

test('shows non-actionable utomated comments if they exist', async () => {
  render(<AnalysisStatusSummary numNonActionableAutomatedComments={3} />)

  expect(
    screen.getByRole('img', { name: 'Automated comments' })
  ).toBeInTheDocument()
  expect(screen.getByTitle('Other')).toBeInTheDocument()
  expect(screen.getByText('3')).toBeInTheDocument()
})
