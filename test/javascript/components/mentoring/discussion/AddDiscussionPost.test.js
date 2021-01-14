import React from 'react'
import { fireEvent, render, waitFor, screen } from '@testing-library/react'
import { rest } from 'msw'
import { setupServer } from 'msw/node'
import '@testing-library/jest-dom/extend-expect'
import { AddDiscussionPost } from '../../../../../app/javascript/components/mentoring/discussion/AddDiscussionPost'
import userEvent from '@testing-library/user-event'

test('shows form after clicking on "Add a comment" button', async () => {
  render(
    <AddDiscussionPost
      endpoint="https://exercism.test/posts"
      contextId="test"
    />
  )

  userEvent.click(screen.getByRole('button', { name: 'Add a comment' }))

  expect(
    await screen.findByRole('button', { name: 'Send' })
  ).toBeInTheDocument()
  expect(
    screen.queryByRole('button', { name: 'Add a comment' })
  ).not.toBeInTheDocument()
})

test('hides form after clicking on "Cancel" button', async () => {
  render(
    <AddDiscussionPost
      endpoint="https://exercism.test/posts"
      contextId="test"
    />
  )

  userEvent.click(screen.getByRole('button', { name: 'Add a comment' }))
  userEvent.click(screen.getByRole('button', { name: 'Cancel' }))

  expect(screen.queryByRole('button', { name: 'Send' })).not.toBeInTheDocument()
  expect(
    screen.queryByRole('button', { name: 'Cancel' })
  ).not.toBeInTheDocument()
})

test('hides form when request succeeds', async () => {
  const server = setupServer(
    rest.post('https://exercism.test/posts', (req, res, ctx) => {
      return res(ctx.status(200), ctx.json({ post: {} }))
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
