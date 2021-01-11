import React from 'react'
import { fireEvent, render, waitFor, screen } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { DiscussionPost } from '../../../../../app/javascript/components/mentoring/discussion/DiscussionPost'

document.createRange = () => {
  const range = new Range()

  range.getBoundingClientRect = jest.fn()

  range.getClientRects = () => {
    return {
      item: () => null,
      length: 0,
      [Symbol.iterator]: jest.fn(),
    }
  }

  return range
}

test('does not display student tag if author is mentor', async () => {
  const post = {
    id: 1,
    authorHandle: 'author',
    authorAvatarUrl: 'http://exercism.test/image',
    byStudent: false,
    contentMarkdown: '# Hello',
    contentHtml: '<p>Hello</p>',
    updatedAt: new Date().toISOString(),
    links: {
      update: 'https://exercism.test/links/1',
    },
  }

  const { queryByText } = render(<DiscussionPost {...post} />)

  expect(queryByText('Student')).not.toBeInTheDocument()
})

test('prefills edit form with previous value', async () => {
  const post = {
    id: 1,
    authorHandle: 'author',
    authorAvatarUrl: 'http://exercism.test/image',
    byStudent: false,
    contentMarkdown: '# Hello',
    contentHtml: '<h1>Hello</h1>',
    updatedAt: new Date().toISOString(),
    links: {
      update: 'https://exercism.test/links/1',
    },
  }

  const { getByText } = render(<DiscussionPost {...post} />)
  fireEvent.click(getByText('Edit'))

  await waitFor(() => {
    const editor = document.querySelector('.CodeMirror').CodeMirror
    expect(editor.getValue()).toEqual('# Hello')
  })
})

test('highlights code blocks', async () => {
  const post = {
    id: 1,
    authorHandle: 'author',
    authorAvatarUrl: 'http://exercism.test/image',
    byStudent: false,
    contentMarkdown: '# My code\n```ruby\nHello\n```',
    contentHtml:
      '<h1>My code</h1><pre><code class="language-ruby">class Hello</code></pre>',
    updatedAt: new Date().toISOString(),
    links: {
      update: 'https://exercism.test/links/1',
    },
  }

  render(<DiscussionPost {...post} />)

  expect(screen.getByText('class')).toHaveAttribute('class', 'hljs-keyword')
  expect(screen.getByText('Hello')).toHaveAttribute('class', 'hljs-title')
})
