import React from 'react'
import { screen } from '@testing-library/react'
import { render } from '../../../test-utils'
import userEvent from '@testing-library/user-event'
import '@testing-library/jest-dom/extend-expect'
import { FinishMentorDiscussionModal } from '@/components/modals/student/FinishMentorDiscussionModal'
import { rest } from 'msw'
import { setupServer } from 'msw/node'

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

  render(
    <FinishMentorDiscussionModal
      open
      links={links}
      discussion={discussion}
      ariaHideApp={false}
    />
  )
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

  render(
    <FinishMentorDiscussionModal
      open
      links={links}
      discussion={discussion}
      ariaHideApp={false}
    />
  )
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

  render(
    <FinishMentorDiscussionModal
      open
      links={links}
      discussion={discussion}
      ariaHideApp={false}
    />
  )
  userEvent.click(screen.getByRole('button', { name: 'Problematic' }))
  userEvent.click(screen.getByRole('button', { name: 'Back' }))

  expect(
    await screen.findByText("It's time to review this discussion")
  ).toBeInTheDocument()
})

test('shows summary of report', async () => {
  const discussion = {
    finishedBy: 'mentor',
    mentor: {
      handle: 'mentor',
    },
    links: {
      finish: 'https://exercism.test/discussions/1/finish',
    },
  }
  const server = setupServer(
    rest.patch(
      'https://exercism.test/discussions/1/finish',
      (req, res, ctx) => {
        return res(ctx.status(200), ctx.json({}))
      }
    )
  )
  server.listen()

  render(
    <FinishMentorDiscussionModal
      open
      discussion={discussion}
      links={{}}
      ariaHideApp={false}
    />
  )
  userEvent.click(screen.getByRole('button', { name: 'Problematic' }))
  userEvent.click(await screen.findByRole('button', { name: 'Finish' }))

  expect(
    await screen.findByText(
      'Your solution has been put back in the queue and another mentor will hopefully pick it up soon. We hope you have a positive mentoring session on this solution next time!'
    )
  ).toBeInTheDocument()
  expect(
    screen.queryByText('Thank you for your report')
  ).not.toBeInTheDocument()
  expect(
    screen.queryByText('We hope you have a better next experience')
  ).not.toBeInTheDocument()

  server.close()
})
