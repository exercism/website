import React from 'react'
import { render, screen } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { DiscussionPostView } from '../../../../../../app/javascript/components/mentoring/discussion/discussion-post/DiscussionPostView'
import { stubRange } from '../../../../support/code-mirror-helpers'
import { createDiscussionPost } from '../../../../factories/DiscussionPostFactory'

stubRange()

test('does not display student tag if author is mentor', async () => {
  render(
    <DiscussionPostView
      item={createDiscussionPost({ byStudent: false })}
      onEdit={jest.fn()}
    />
  )

  expect(screen.queryByText('Student')).not.toBeInTheDocument()
})

test('highlights code blocks', async () => {
  render(
    <DiscussionPostView
      item={createDiscussionPost({
        contentMarkdown: '# My code\n```ruby\nHello\n```',
        contentHtml:
          '<h1>My code</h1><pre><code class="language-ruby">class Hello</code></pre>',
      })}
      onEdit={jest.fn()}
    />
  )

  expect(screen.getByText('class')).toHaveAttribute('class', 'hljs-keyword')
  expect(screen.getByText('Hello')).toHaveAttribute(
    'class',
    'hljs-title class_'
  )
})
