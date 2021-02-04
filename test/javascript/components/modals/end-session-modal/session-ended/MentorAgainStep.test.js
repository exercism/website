import React from 'react'
import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { rest } from 'msw'
import { setupServer } from 'msw/node'
import '@testing-library/jest-dom/extend-expect'
import { MentorAgainStep } from '../../../../../../app/javascript/components/modals/end-session-modal/session-ended/MentorAgainStep'
import { silenceConsole } from '../../../../support/silence-console'

test('disables buttons when choosing to mentor again', async () => {
  const discussion = {
    student: {
      handle: 'student',
    },
    relationship: {
      links: {
        mentorAgain: 'https://exercism.test/mentor_again',
      },
    },
  }
  const server = setupServer(
    rest.patch('https://exercism.test/mentor_again', (req, res, ctx) => {
      return res(ctx.status(200), ctx.json({ relationship: {} }))
    })
  )
  server.listen()

  render(<MentorAgainStep discussion={discussion} />)
  userEvent.click(screen.getByRole('button', { name: 'Yes' }))

  expect(await screen.findByRole('button', { name: 'Yes' })).toBeDisabled()
  expect(screen.getByRole('button', { name: 'No' })).toBeDisabled()

  server.close()
})

test('shows loading message when choosing to mentor again', async () => {
  const discussion = {
    student: {
      handle: 'student',
    },
    relationship: {
      links: {
        mentorAgain: 'https://exercism.test/mentor_again',
      },
    },
  }
  const server = setupServer(
    rest.patch('https://exercism.test/mentor_again', (req, res, ctx) => {
      return res(ctx.status(200), ctx.json({ relationship: {} }))
    })
  )
  server.listen()

  render(<MentorAgainStep discussion={discussion} />)
  userEvent.click(screen.getByRole('button', { name: 'Yes' }))

  expect(await screen.findByText('Loading')).toBeInTheDocument()

  server.close()
})

test('shows API errors when choosing to mentor again', async () => {
  silenceConsole()
  const discussion = {
    student: {
      handle: 'student',
    },
    relationship: {
      links: {
        mentorAgain: 'https://exercism.test/mentor_again',
      },
    },
  }
  const server = setupServer(
    rest.patch('https://exercism.test/mentor_again', (req, res, ctx) => {
      return res(
        ctx.status(422),
        ctx.json({
          error: { message: 'Unable to update student-mentor relationship' },
        })
      )
    })
  )
  server.listen()

  render(<MentorAgainStep discussion={discussion} />)
  userEvent.click(screen.getByRole('button', { name: 'Yes' }))

  expect(
    await screen.findByText('Unable to update student-mentor relationship')
  ).toBeInTheDocument()

  server.close()
})

test('shows generic error when choosing to mentor again', async () => {
  silenceConsole()
  const discussion = {
    student: {
      handle: 'student',
    },
    relationship: {
      links: {
        mentorAgain: 'wrongendpoint',
      },
    },
  }

  render(<MentorAgainStep discussion={discussion} />)
  userEvent.click(screen.getByRole('button', { name: 'Yes' }))

  expect(
    await screen.findByText('Unable to update student-mentor relationship')
  ).toBeInTheDocument()
})
test('disables buttons when choosing to not mentor again', async () => {
  const discussion = {
    student: {
      handle: 'student',
    },
    relationship: {
      links: {
        dontMentorAgain: 'https://exercism.test/dont_mentor_again',
      },
    },
  }
  const server = setupServer(
    rest.patch('https://exercism.test/dont_mentor_again', (req, res, ctx) => {
      return res(ctx.status(200), ctx.json({ relationship: {} }))
    })
  )
  server.listen()

  render(<MentorAgainStep discussion={discussion} />)
  userEvent.click(screen.getByRole('button', { name: 'No' }))

  expect(await screen.findByRole('button', { name: 'Yes' })).toBeDisabled()
  expect(screen.getByRole('button', { name: 'No' })).toBeDisabled()

  server.close()
})

test('shows loading message when choosing to not mentor again', async () => {
  const discussion = {
    student: {
      handle: 'student',
    },
    relationship: {
      links: {
        dontMentorAgain: 'https://exercism.test/dont_mentor_again',
      },
    },
  }
  const server = setupServer(
    rest.patch('https://exercism.test/dont_mentor_again', (req, res, ctx) => {
      return res(ctx.status(200), ctx.json({ relationship: {} }))
    })
  )
  server.listen()

  render(<MentorAgainStep discussion={discussion} />)
  userEvent.click(screen.getByRole('button', { name: 'No' }))

  expect(await screen.findByText('Loading')).toBeInTheDocument()

  server.close()
})

test('shows API errors when choosing to not mentor again', async () => {
  silenceConsole()
  const discussion = {
    student: {
      handle: 'student',
    },
    relationship: {
      links: {
        dontMentorAgain: 'https://exercism.test/dont_mentor_again',
      },
    },
  }
  const server = setupServer(
    rest.patch('https://exercism.test/dont_mentor_again', (req, res, ctx) => {
      return res(
        ctx.status(422),
        ctx.json({
          error: { message: 'Unable to update student-mentor relationship' },
        })
      )
    })
  )
  server.listen()

  render(<MentorAgainStep discussion={discussion} />)
  userEvent.click(screen.getByRole('button', { name: 'No' }))

  expect(
    await screen.findByText('Unable to update student-mentor relationship')
  ).toBeInTheDocument()

  server.close()
})

test('shows generic error when choosing to not mentor again', async () => {
  silenceConsole()
  const discussion = {
    student: {
      handle: 'student',
    },
    relationship: {
      links: {
        dontMentorAgain: 'wrongendpoint',
      },
    },
  }

  render(<MentorAgainStep discussion={discussion} />)
  userEvent.click(screen.getByRole('button', { name: 'No' }))

  expect(
    await screen.findByText('Unable to update student-mentor relationship')
  ).toBeInTheDocument()
})
