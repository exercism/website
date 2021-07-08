import React from 'react'
import { render, screen, waitFor } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { DiscussionPost } from '../../../../../app/javascript/components/mentoring/discussion/DiscussionPost'
import userEvent from '@testing-library/user-event'
import { stubRange } from '../../../support/code-mirror-helpers'
import { act } from 'react-dom/test-utils'
import { createDiscussionPost } from '../../../factories/DiscussionPostFactory'

stubRange()

test('clicking edit opens edit form', async () => {
  render(<DiscussionPost post={createDiscussionPost({})} />)

  await act(async () =>
    userEvent.click(screen.getByRole('button', { name: /Edit/ }))
  )

  expect(await screen.findByTestId('markdown-editor')).toBeInTheDocument()
})

test('clicking cancel closes edit form', async () => {
  render(
    <DiscussionPost post={createDiscussionPost({})} defaultAction="editing" />
  )

  await act(async () =>
    userEvent.click(screen.getByRole('button', { name: 'Cancel' }))
  )

  await waitFor(() =>
    expect(screen.queryByTestId('markdown-editor')).not.toBeInTheDocument()
  )
})
