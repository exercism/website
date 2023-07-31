import React from 'react'
import { render, screen } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { IterationSummary } from '../../../../app/javascript/components/track/IterationSummary'
import { createIteration } from '../../factories/IterationFactory'
import {
  SubmissionMethod,
  SubmissionTestsStatus,
} from '../../../../app/javascript/components/types'

test('shows details', async () => {
  const iteration = createIteration({
    idx: 2,
    submissionMethod: SubmissionMethod.CLI,
    createdAt: new Date().toISOString(),
    testsStatus: SubmissionTestsStatus.QUEUED,
    numEssentialAutomatedComments: 2,
  })

  render(
    <IterationSummary
      iteration={iteration}
      showSubmissionMethod={true}
      showFeedbackIndicator={true}
      showTestsStatusAsButton={false}
    />
  )

  expect(screen.getByText('Iteration 2')).toBeInTheDocument()
  expect(screen.getByAltText('Submitted via CLI')).toBeInTheDocument()
  expect(screen.getByTestId('details')).toHaveTextContent(
    'Submitted via CLI, a few seconds ago'
  )
  expect(
    screen.getByRole('status', { name: 'Processing status' })
  ).toHaveTextContent('Passed')
  expect(
    screen.getByRole('status', { name: 'Analysis status' })
  ).toHaveTextContent('2')
})

test('honours showSubmissionMethod', async () => {
  const iteration = createIteration({
    idx: 2,
    submissionMethod: SubmissionMethod.CLI,
  })

  render(
    <IterationSummary
      iteration={iteration}
      showSubmissionMethod={false}
      showFeedbackIndicator={true}
      showTestsStatusAsButton={false}
    />
  )

  expect(screen.queryByAltText('Submitted via CLI')).not.toBeInTheDocument()
})

test('shows published tag when published', async () => {
  const iteration = createIteration({ isPublished: true })

  render(
    <IterationSummary
      iteration={iteration}
      showSubmissionMethod={false}
      showFeedbackIndicator={true}
      showTestsStatusAsButton={false}
    />
  )

  expect(screen.getByText('Published')).toBeInTheDocument()
})

test('hides published tag when not published', async () => {
  const iteration = createIteration({ isPublished: false })

  render(
    <IterationSummary
      iteration={iteration}
      showSubmissionMethod={false}
      showFeedbackIndicator={true}
      showTestsStatusAsButton={false}
    />
  )

  expect(screen.queryByText('Published')).not.toBeInTheDocument()
})

test('renders out of date notice', async () => {
  const iteration = createIteration({ isPublished: false })
  const Notice = () => <span>Outdated</span>

  render(
    <IterationSummary
      iteration={iteration}
      showSubmissionMethod={false}
      showFeedbackIndicator={true}
      showTestsStatusAsButton={false}
      OutOfDateNotice={<Notice />}
    />
  )

  expect(screen.getByText('Outdated')).toBeInTheDocument()
})
