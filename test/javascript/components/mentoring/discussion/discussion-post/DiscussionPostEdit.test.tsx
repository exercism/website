import React from 'react'
import { render } from '../../../../test-utils'
import { waitFor } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { DiscussionPostEdit } from '../../../../../../app/javascript/components/mentoring/discussion/discussion-post/DiscussionPostEdit'
import { stubRange } from '../../../../support/code-mirror-helpers'
import { createDiscussionPost } from '../../../../factories/DiscussionPostFactory'

stubRange()

test('prefills form with previous value', async () => {
  render(
    <DiscussionPostEdit
      item={createDiscussionPost({ contentMarkdown: '# Hello' })}
      onSuccess={jest.fn()}
      onCancel={jest.fn()}
    />
  )

  await waitFor(() => {
    const editor = document.querySelector('.CodeMirror').CodeMirror
    expect(editor.getValue()).toEqual('# Hello')
  })
})
test('closing form resets text to original value', async () => {
  // TODO: It's hard to assert on the text editor value
})
