import React from 'react'
import { render } from '../../../test-utils'
import { screen, waitFor } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { DiscussionPost } from '../../../../../app/javascript/components/mentoring/discussion/DiscussionPost'
import { stubRange } from '../../../support/code-mirror-helpers'
import { createDiscussionPost } from '../../../factories/DiscussionPostFactory'

stubRange()

test('editing action shows editor', async () => {
  render(<DiscussionPost post={createDiscussionPost({})} action="editing" />)

  await waitFor(() =>
    expect(screen.getByTestId('markdown-editor')).toBeInTheDocument()
  )
})

test('viewing action does not show editor', async () => {
  render(<DiscussionPost post={createDiscussionPost({})} action="viewing" />)

  expect(screen.queryByTestId('markdown-editor')).not.toBeInTheDocument()
})
