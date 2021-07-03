import React from 'react'
import { render, screen } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { EditDiscussionPost } from '../../../../../app/javascript/components/mentoring/discussion/EditDiscussionPost'
import userEvent from '@testing-library/user-event'
import { stubRange } from '../../../support/code-mirror-helpers'
import { act } from 'react-dom/test-utils'

stubRange()

test('clicking cancel closes form', async () => {
  render(
    <EditDiscussionPost
      endpoint="https://exercism.test/posts"
      contextId="test"
    />
  )

  const button = screen.getByRole('button', { name: /Edit/ })
  await act(async () => userEvent.click(button))
  await act(async () =>
    userEvent.click(screen.getByRole('button', { name: 'Cancel' }))
  )
  expect(screen.queryByTestId('markdown-editor')).not.toBeInTheDocument()
})

test('closing form resets text to original value', async () => {
  // TODO: It's hard to assert on the text editor value
})
