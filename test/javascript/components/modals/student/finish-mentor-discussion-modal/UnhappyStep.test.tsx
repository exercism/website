import React from 'react'
import { render, screen } from '@testing-library/react'
import { UnhappyStep } from '../../../../../../app/javascript/components/modals/student/finish-mentor-discussion-modal/UnhappyStep'

test('shows message when a report is sent', async () => {
  const links = {
    exercise: '',
  }
  const report = { report: true, requeue: true }

  render(<UnhappyStep report={report} links={links} />)

  expect(screen.getByText('Thank you for your report')).toBeInTheDocument()
})

test('shows message when a solution is requeued', async () => {
  const links = {
    exercise: '',
  }
  const report = { report: false, requeue: true }

  render(<UnhappyStep report={report} links={links} />)

  expect(
    screen.getByText(
      'Your solution has been put back in the queue and another mentor will hopefully pick it up soon. We hope you have a positive mentoring session on this solution next time!'
    )
  ).toBeInTheDocument()
})

test('shows message when a report is not submitted and a solution is not requeued', async () => {
  const links = {
    exercise: '',
  }
  const report = { report: false, requeue: false }

  render(<UnhappyStep report={report} links={links} />)

  expect(
    screen.getByText('We hope you have a better next experience')
  ).toBeInTheDocument()
})
