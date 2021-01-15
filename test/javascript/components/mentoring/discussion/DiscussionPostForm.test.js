import React from 'react'
import { fireEvent, render, waitFor, screen } from '@testing-library/react'
import { rest } from 'msw'
import { setupServer } from 'msw/node'
import '@testing-library/jest-dom/extend-expect'
import { DiscussionPostForm } from '../../../../../app/javascript/components/mentoring/discussion/DiscussionPostForm'
import { silenceConsole } from '../../../support/silence-console'
import userEvent from '@testing-library/user-event'

test('shows loading message while sending posts', async () => {
  const server = setupServer(
    rest.post('https://exercism.test/posts', (req, res, ctx) => {
      return res(ctx.status(200), ctx.json({ post: {} }))
    })
  )
  server.listen()

  const { getByText, queryByText } = render(
    <DiscussionPostForm
      method="POST"
      endpoint="https://exercism.test/posts"
      contextId="test"
    />
  )
  fireEvent.click(getByText('Send'))

  await waitFor(() => expect(queryByText('Loading')).toBeInTheDocument())
  await waitFor(() => expect(queryByText('Loading')).not.toBeInTheDocument())

  server.close()
})

test('send button should be disabled while sending', async () => {
  const server = setupServer(
    rest.post('https://exercism.test/posts', (req, res, ctx) => {
      return res(ctx.status(200), ctx.json({ post: {} }))
    })
  )
  server.listen()

  const { getByText } = render(
    <DiscussionPostForm
      method="POST"
      endpoint="https://exercism.test/posts"
      contextId="test"
    />
  )
  fireEvent.click(getByText('Send'))

  expect(getByText('Send')).toBeDisabled()

  server.close()
})

test('shows error messages when error occurs during sending', async () => {
  silenceConsole()
  const server = setupServer(
    rest.post('https://exercism.test/posts', (req, res, ctx) => {
      return res(
        ctx.status(403),
        ctx.json({
          error: {
            type: 'unauthorized',
            message: 'Unauthorized',
          },
        })
      )
    })
  )
  server.listen()

  render(
    <DiscussionPostForm
      method="POST"
      endpoint="https://exercism.test/posts"
      contextId="test"
    />
  )
  userEvent.click(screen.getByRole('button', { name: 'Send' }))

  expect(await screen.findByText('Unauthorized')).toBeInTheDocument()

  server.close()
})
