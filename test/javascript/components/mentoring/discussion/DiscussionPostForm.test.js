import React from 'react'
import { render, waitFor, screen } from '@testing-library/react'
import { rest } from 'msw'
import { setupServer } from 'msw/node'
import '@testing-library/jest-dom/extend-expect'
import { DiscussionPostForm } from '../../../../../app/javascript/components/mentoring/discussion/DiscussionPostForm'
import { silenceConsole } from '../../../support/silence-console'
import userEvent from '@testing-library/user-event'
import { stubRange } from '../../../support/code-mirror-helpers'

stubRange()

test('send button should be disabled while sending', async () => {
  const server = setupServer(
    rest.post('https://exercism.test/posts', (req, res, ctx) => {
      return res(ctx.status(200), ctx.json({ post: {} }))
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
  const button = screen.getByRole('button', { name: /Send/ })
  userEvent.click(button)

  await waitFor(() => expect(button).toBeDisabled())

  server.close()
})

test('send button should be disabled when there is no value', async () => {
  render(
    <DiscussionPostForm
      method="POST"
      endpoint="https://exercism.test/posts"
      contextId="test"
      expanded
    />
  )
  const button = screen.getByRole('button', { name: /Send/ })

  await waitFor(() => expect(button).toBeDisabled())
})

test('hides buttons when form is compressed', async () => {
  render(
    <DiscussionPostForm
      method="POST"
      endpoint="https://exercism.test/posts"
      contextId="test"
      value="Hello"
      expanded={false}
    />
  )

  await waitFor(() => {
    expect(
      screen.queryByRole('button', { name: /Send/ })
    ).not.toBeInTheDocument()
    expect(
      screen.queryByRole('button', { name: /Cancel/ })
    ).not.toBeInTheDocument()
  })
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
      value="Hello"
    />
  )
  userEvent.click(screen.getByRole('button', { name: 'Send' }))

  expect(await screen.findByText('Unauthorized')).toBeInTheDocument()

  server.close()
})

test('focuses text editor when expanded', async () => {
  render(
    <DiscussionPostForm
      method="POST"
      endpoint="https://exercism.test/posts"
      contextId="test"
      expanded
    />
  )

  await waitFor(() => {
    const editor = document.querySelector('.CodeMirror')

    expect(editor).toHaveAttribute(
      'class',
      'CodeMirror cm-s-easymde CodeMirror-wrap CodeMirror-focused'
    )
  })
})
