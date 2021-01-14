import React from 'react'
import { render, screen } from '@testing-library/react'
import { rest } from 'msw'
import { setupServer } from 'msw/node'
import '@testing-library/jest-dom/extend-expect'
import { DiscussionPostList } from '../../../../../app/javascript/components/mentoring/discussion/DiscussionPostList'

window.IntersectionObserver = jest.fn(() => ({
  observe: jest.fn(),
  unobserve: jest.fn(),
  disconnect: jest.fn(),
}))

test('displays all posts', async () => {
  stubScroll()
  const twoDaysAgo = new Date(new Date() - 1000 * 60 * 60 * 24 * 2)
  const posts = [
    {
      id: 1,
      author_handle: 'author',
      author_avatar_url: 'http://exercism.test/image',
      by_student: true,
      content_html: '<p>Hello</p>',
      updated_at: new Date().toISOString(),
      iteration_idx: 1,
      links: {
        self: 'https://exercism.test/posts/1',
      },
    },
    {
      id: 2,
      author_handle: 'other-author',
      author_avatar_url: 'http://exercism.test/other-image',
      by_student: false,
      content_html: '<p>Goodbye</p>',
      updated_at: twoDaysAgo.toISOString(),
      iteration_idx: 2,
      links: {
        self: 'https://exercism.test/posts/2',
      },
    },
  ]
  const server = setupServer(
    rest.get('https://exercism.test/posts', (req, res, ctx) => {
      return res(ctx.json({ posts: posts }))
    })
  )
  server.listen()

  render(<DiscussionPostList endpoint="https://exercism.test/posts" />)

  expect(
    await screen.findByRole('status', {
      name: 'Discussion post list loading indicator',
    })
  ).toBeInTheDocument()

  expect(await screen.findByText('author')).toBeInTheDocument()
  expect(
    await screen.findByRole('img', { name: 'Uploaded avatar of author' })
  ).toHaveAttribute('src', 'http://exercism.test/image')
  expect(await screen.findByText('Student')).toBeInTheDocument()
  expect(await screen.findByText('Hello')).toBeInTheDocument()
  expect(await screen.findByText('a few seconds ago')).toBeInTheDocument()
  expect(
    await screen.findByRole('img', { name: 'Uploaded avatar of other-author' })
  ).toHaveAttribute('src', 'http://exercism.test/other-image')
  expect(await screen.findByText('other-author')).toBeInTheDocument()
  expect(await screen.findByText('Student')).toBeInTheDocument()
  expect(await screen.findByText('Goodbye')).toBeInTheDocument()
  expect(await screen.findByText('2 days ago')).toBeInTheDocument()
  expect(
    screen.queryByRole('status', {
      name: 'Discussion post list loading indicator',
    })
  ).not.toBeInTheDocument()

  server.close()
})

function stubScroll() {
  Element.prototype.scrollIntoView = jest.fn()
}
