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
  const discussion = {
    finishedBy: 'mentor',
    mentor: {
      handle: 'mentor',
    },
  }

  render(<FinishMentorDiscussionModal links={links} discussion={discussion} />)
  userEvent.click(screen.getByRole('button', { name: 'It was good!' }))
  userEvent.click(screen.getByRole('button', { name: 'Back' }))

  expect(
    await screen.findByText("It's time to review this discussion")
  ).toBeInTheDocument()
})

test('has back button in satisfied step', async () => {
  const links = {
    exercise: '',
    finish: '',
  }
  const discussion = {
    finishedBy: 'mentor',
    mentor: {
      handle: 'mentor',
    },
  }

  render(<FinishMentorDiscussionModal links={links} discussion={discussion} />)
  userEvent.click(screen.getByRole('button', { name: 'Acceptable' }))
  userEvent.click(screen.getByRole('button', { name: 'Back' }))

  expect(
    await screen.findByText("It's time to review this discussion")
  ).toBeInTheDocument()
})

test('has back button in report step', async () => {
  const links = {
    exercise: '',
    finish: '',
  }
  const discussion = {
    finishedBy: 'mentor',
    mentor: {
      handle: 'mentor',
    },
  }

  render(<FinishMentorDiscussionModal links={links} discussion={discussion} />)
  userEvent.click(screen.getByRole('button', { name: 'Problematic' }))
  userEvent.click(screen.getByRole('button', { name: 'Back' }))

  expect(
    await screen.findByText("It's time to review this discussion")
  ).toBeInTheDocument()
})
