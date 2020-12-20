import React from 'react'
import { fireEvent, render, waitFor } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { DiscussionPost } from '../../../../app/javascript/components/mentoring/DiscussionPost'

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
      self: 'https://exercism.test/links/1',
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
      self: 'https://exercism.test/links/1',
    },
  }

  const { getByText } = render(<DiscussionPost {...post} />)
  fireEvent.click(getByText('Edit'))

  await waitFor(() => {
    const editor = document.querySelector('.CodeMirror').CodeMirror
    expect(editor.getValue()).toEqual('# Hello')
  })
})
