import React from 'react'
import { render, screen, waitFor } from '@testing-library/react'
import { rest } from 'msw'
import { setupServer } from 'msw/node'
import '@testing-library/jest-dom/extend-expect'
import { StartDiscussionPanel } from '../../../../../app/javascript/components/mentoring/request/StartDiscussionPanel'
import { silenceConsole } from '../../../support/silence-console'
import userEvent from '@testing-library/user-event'

test('shows loading message while locking mentoring request', async () => {
  const request = {
    links: {
      discussion: 'https://exercism.test/discussion',
    },
  }
  const iterations = [{ idx: 1 }]
  const server = setupServer(
    rest.post('https://exercism.test/discussion', (req, res, ctx) => {
      return res(ctx.status(200), ctx.json({ discussion: {} }))
    })
  )
  server.listen()

  render(<StartDiscussionPanel request={request} iterations={iterations} />)
  userEvent.click(screen.getByRole('button', { name: 'Send' }))

  expect(screen.getByText('Loading')).toBeInTheDocument()

  server.close()
})

test('disables button while locking mentoring request', async () => {
  const request = {
    links: {
      discussion: 'https://exercism.test/discussion',
    },
  }
  const iterations = [{ idx: 1 }]
  const server = setupServer(
    rest.post('https://exercism.test/discussion', (req, res, ctx) => {
      return res(ctx.status(200), ctx.json({ discussion: {} }))
    })
  )
  server.listen()

  render(
    <StartDiscussionPanel
      request={request}
      iterations={iterations}
      setDiscussion={() => {}}
    />
  )
  const sendButton = screen.getByRole('button', { name: 'Send' })
  userEvent.click(sendButton)

  await waitFor(() => expect(sendButton).toBeDisabled())

  server.close()
})

test('shows API errors', async () => {
  silenceConsole()
  const request = {
    links: {
      discussion: 'https://exercism.test/discussion',
    },
  }
  const iterations = [{ idx: 1 }]
  const server = setupServer(
    rest.post('https://exercism.test/discussion', (req, res, ctx) => {
      return res(
        ctx.status(422),
        ctx.json({
          error: {
            message: 'Unable to start discussion',
          },
        })
      )
    })
  )
  server.listen()

  render(<StartDiscussionPanel request={request} iterations={iterations} />)
  userEvent.click(screen.getByRole('button', { name: 'Send' }))

  expect(
    await screen.findByText('Unable to start discussion')
  ).toBeInTheDocument()

  server.close()
})

test('shows generic errors', async () => {
  silenceConsole()
  const request = {
    links: {
      discussion: 'https://exercism.test/discussion',
    },
  }
  const iterations = [{ idx: 1 }]

  render(<StartDiscussionPanel request={request} iterations={iterations} />)
  userEvent.click(screen.getByRole('button', { name: 'Send' }))

  expect(
    await screen.findByText('Unable to start discussion')
  ).toBeInTheDocument()
})
