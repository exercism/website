import React from 'react'
import { render, waitFor } from '@testing-library/react'
import { rest } from 'msw'
import { setupServer } from 'msw/node'
import '@testing-library/jest-dom/extend-expect'
import { DiscussionPostList } from '../../../../app/javascript/components/mentoring/DiscussionPostList'

test('displays all posts', async () => {
  const server = setupServer(
    rest.get('https://exercism.test/posts', (req, res, ctx) => {
      return res(
        ctx.json([
          {
            id: 1,
            author_handle: 'author',
            author_avatar_url: 'http://exercism.test/image',
            from_student: true,
            content_html: '<p>Hello</p>',
            updated_at: new Date().toISOString(),
          },
        ])
      )
    })
  )
  server.listen()

  const { queryByText, getByTestId } = render(
    <DiscussionPostList endpoint="https://exercism.test/posts" />
  )

  await waitFor(() => {
    expect(getByTestId('author-avatar')).toHaveAttribute(
      'src',
      'http://exercism.test/image'
    )
    expect(queryByText('author')).toBeInTheDocument()
    expect(queryByText('Student')).toBeInTheDocument()
    expect(queryByText('Hello')).toBeInTheDocument()
    expect(queryByText('a few seconds ago')).toBeInTheDocument()
  })

  server.close()
})
