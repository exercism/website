import React from 'react'
import { fireEvent, render, waitFor } from '@testing-library/react'
import { rest } from 'msw'
import { setupServer } from 'msw/node'
import '@testing-library/jest-dom/extend-expect'
import { DiscussionPostForm } from '../../../../app/javascript/components/mentoring/DiscussionPostForm'

test('shows loading message', async () => {
  const server = setupServer(
    rest.post('https://exercism.test/posts', (req, res, ctx) => {
      return res(ctx.status(200), ctx.json({}))
    })
  )
  server.listen()

  const { getByText, queryByText } = render(
    <DiscussionPostForm
      endpoint="https://exercism.test/posts"
      contextId="test"
    />
  )
  fireEvent.click(getByText('Add a comment'))
  fireEvent.click(getByText('Send'))

  await waitFor(() => expect(queryByText('Loading...')).toBeInTheDocument())
  await waitFor(() => expect(queryByText('Loading...')).not.toBeInTheDocument())
})

test('closes panel when request succeeds', async () => {
  const server = setupServer(
    rest.post('https://exercism.test/posts', (req, res, ctx) => {
      return res(ctx.status(200), ctx.json({}))
    })
  )
  server.listen()

  const { getByText, queryByText } = render(
    <DiscussionPostForm
      endpoint="https://exercism.test/posts"
      contextId="test"
    />
  )
  fireEvent.click(getByText('Add a comment'))
  fireEvent.click(getByText('Send'))

  await waitFor(() => expect(queryByText('Send')).not.toBeInTheDocument())
})
