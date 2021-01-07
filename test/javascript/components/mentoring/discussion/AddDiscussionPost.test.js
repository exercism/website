import React from 'react'
import { fireEvent, render, waitFor } from '@testing-library/react'
import { rest } from 'msw'
import { setupServer } from 'msw/node'
import '@testing-library/jest-dom/extend-expect'
import { AddDiscussionPost } from '../../../../../app/javascript/components/mentoring/discussion/AddDiscussionPost'

test('shows loading message while fetching posts', async () => {
  const server = setupServer(
    rest.post('https://exercism.test/posts', (req, res, ctx) => {
      return res(ctx.status(200), ctx.json({}))
    })
  )
  server.listen()

  const { getByText, queryByText } = render(
    <AddDiscussionPost
      endpoint="https://exercism.test/posts"
      contextId="test"
    />
  )
  fireEvent.click(getByText('Add a comment'))
  fireEvent.click(getByText('Send'))

  await waitFor(() => expect(queryByText('Loading')).toBeInTheDocument())
  await waitFor(() => expect(queryByText('Loading')).not.toBeInTheDocument())

  server.close()
})

test('send button should be disabled while sending', async () => {
  const server = setupServer(
    rest.post('https://exercism.test/posts', (req, res, ctx) => {
      return res(ctx.status(200), ctx.json({}))
    })
  )
  server.listen()

  const { getByText, queryByText } = render(
    <AddDiscussionPost
      endpoint="https://exercism.test/posts"
      contextId="test"
    />
  )
  fireEvent.click(getByText('Add a comment'))
  fireEvent.click(getByText('Send'))

  expect(getByText('Send')).toBeDisabled()
  await waitFor(() => expect(queryByText('Send')).not.toBeInTheDocument())

  server.close()
})

test('shows error messages when error occurs during fetching', async () => {
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

  const { getByText, queryByText } = render(
    <AddDiscussionPost
      endpoint="https://exercism.test/posts"
      contextId="test"
    />
  )
  fireEvent.click(getByText('Add a comment'))
  fireEvent.click(getByText('Send'))

  await waitFor(() => expect(queryByText('Unauthorized')).toBeInTheDocument())

  server.close()
})

test('closes panel when request succeeds', async () => {
  const server = setupServer(
    rest.post('https://exercism.test/posts', (req, res, ctx) => {
      return res(ctx.status(200), ctx.json({}))
    })
  )
  server.listen()

  const { getByText, queryByText } = render(
    <AddDiscussionPost
      endpoint="https://exercism.test/posts"
      contextId="test"
    />
  )
  fireEvent.click(getByText('Add a comment'))
  fireEvent.click(getByText('Send'))

  await waitFor(() => expect(queryByText('Send')).not.toBeInTheDocument())

  server.close()
})
