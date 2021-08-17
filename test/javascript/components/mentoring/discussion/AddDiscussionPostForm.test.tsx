import React from 'react'
import { waitFor, screen } from '@testing-library/react'
import { render } from '../../../test-utils'
import { rest } from 'msw'
import { setupServer } from 'msw/node'
import '@testing-library/jest-dom/extend-expect'
import { AddDiscussionPostForm } from '../../../../../app/javascript/components/mentoring/discussion/AddDiscussionPostForm'
import userEvent from '@testing-library/user-event'
import { stubRange } from '../../../support/code-mirror-helpers'
import { act } from 'react-dom/test-utils'
import { createMentorDiscussion } from '../../../factories/MentorDiscussionFactory'

stubRange()

const server = setupServer(
  rest.post('http://exercism.test/posts', (req, res, ctx) => {
    return res(ctx.status(200), ctx.json({ item: {} }))
  })
)

beforeAll(() => server.listen())
afterAll(() => server.close())

test('expands and compresses form', async () => {
  render(
    <AddDiscussionPostForm
      discussion={createMentorDiscussion({})}
      onSuccess={jest.fn()}
    />
  )

  const editor = screen.getByTestId('markdown-editor')

  userEvent.click(editor)
  await waitFor(() =>
    expect(editor).toHaveAttribute('class', 'c-markdown-editor --expanded')
  )

  userEvent.click(screen.getByRole('button', { name: 'Cancel' }))
  await waitFor(() =>
    expect(editor).toHaveAttribute('class', 'c-markdown-editor --compressed')
  )
})

test.skip('clears text when clicking the Cancel button', async () => {
  // TODO: It's hard to assert on the text editor being cleared
})

test('when request succeeds, form is compressed', async () => {
  const handleSuccess = jest.fn()
  const discussion = createMentorDiscussion({
    links: {
      posts: 'http://exercism.test/posts',
      self: 'https://exercism.test/discussions/1',
      markAsNothingToDo:
        'https://exercism.test/discussions/1/mark_as_nothing_to_do',
      finish: 'https://exercism.test/discussions/1/finish',
    },
  })
  render(
    <AddDiscussionPostForm discussion={discussion} onSuccess={handleSuccess} />
  )
  const editor = screen.getByTestId('markdown-editor')
  userEvent.click(editor)
  await waitFor(() =>
    expect(editor).toHaveAttribute('class', 'c-markdown-editor --expanded')
  )
  const textarea = screen.getByRole('textbox')
  await act(async () => userEvent.type(textarea, 'Hello'))
  const sendButton = await screen.findByRole('button', { name: /send/i })
  userEvent.click(sendButton)

  await waitFor(() => expect(handleSuccess).toHaveBeenCalled())
  expect(editor).toHaveAttribute('class', 'c-markdown-editor --compressed')
})
