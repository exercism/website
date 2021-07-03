import React from 'react'
import { render, waitFor, screen } from '@testing-library/react'
import { rest } from 'msw'
import { setupServer } from 'msw/node'
import '@testing-library/jest-dom/extend-expect'
import { AddDiscussionPost } from '../../../../../app/javascript/components/mentoring/discussion/AddDiscussionPost'
import userEvent from '@testing-library/user-event'
import { stubRange } from '../../../support/code-mirror-helpers'
import { TestQueryCache } from '../../../support/TestQueryCache'
import { act } from 'react-dom/test-utils'

stubRange()

test('expands and compresses form', async () => {
  render(
    <AddDiscussionPost
      endpoint="https://exercism.test/posts"
      contextId="test"
    />
  )

  const editor = screen.getByTestId('markdown-editor')

  await act(async () => userEvent.click(editor))
  expect(editor).toHaveAttribute('class', 'c-markdown-editor --expanded')

  await act(async () =>
    userEvent.click(screen.getByRole('button', { name: 'Cancel' }))
  )
  expect(editor).toHaveAttribute('class', 'c-markdown-editor --compressed')
})

test.skip('clears text when clicking the Cancel button', async () => {
  // TODO: It's hard to assert on the text editor being cleared
})

test('when request succeeds, form is compressed', async () => {
  const server = setupServer(
    rest.post('http://exercism.test/posts', (req, res, ctx) => {
      return res(ctx.status(200), ctx.json({ post: {} }))
    })
  )
  server.listen()

  render(
    <TestQueryCache>
      <AddDiscussionPost
        endpoint="http://exercism.test/posts"
        contextId="test"
      />
    </TestQueryCache>
  )
  const editor = screen.getByTestId('markdown-editor')
  await act(async () => userEvent.click(editor))
  const textarea = screen.getByRole('textbox')
  await act(async () => userEvent.type(textarea, 'Hello'))
  const sendButton = screen.getByRole('button', { name: 'Send' })
  await act(async () => userEvent.click(sendButton))

  await waitFor(() =>
    expect(editor).toHaveAttribute('class', 'c-markdown-editor --compressed')
  )
  // TODO: Assert text is cleared.

  server.close()
  localStorage.clear()
})
