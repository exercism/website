import React from 'react'
import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import '@testing-library/jest-dom/extend-expect'
import { FinishMentorDiscussionModal } from '../../../../../app/javascript/components/modals/student/FinishMentorDiscussionModal'

test('has back button in add testimonial step', async () => {
  const links = {
    exercise: '',
    finish: '',
  }

  render(<FinishMentorDiscussionModal links={links} />)
  userEvent.click(screen.getByRole('button', { name: 'Happy' }))
  userEvent.click(screen.getByRole('button', { name: 'Back' }))

  expect(
    await screen.findByText("It's time to rate your mentor")
  ).toBeInTheDocument()
})

test('has back button in satisfied step', async () => {
  const links = {
    exercise: '',
    finish: '',
  }

  render(<FinishMentorDiscussionModal links={links} />)
  userEvent.click(screen.getByRole('button', { name: 'Satisfied' }))
  userEvent.click(screen.getByRole('button', { name: 'Back' }))

  expect(
    await screen.findByText("It's time to rate your mentor")
  ).toBeInTheDocument()
})

test('has back button in report step', async () => {
  const links = {
    exercise: '',
    finish: '',
  }

  render(<FinishMentorDiscussionModal links={links} />)
  userEvent.click(screen.getByRole('button', { name: 'Unhappy' }))
  userEvent.click(screen.getByRole('button', { name: 'Back' }))

  expect(
    await screen.findByText("It's time to rate your mentor")
  ).toBeInTheDocument()
})
