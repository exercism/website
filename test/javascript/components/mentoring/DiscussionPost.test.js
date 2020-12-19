import React from 'react'
import { render } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { DiscussionPost } from '../../../../app/javascript/components/mentoring/DiscussionPost'

test('does not display student tag if author is mentor', async () => {
  const post = {
    id: 1,
    author_handle: 'author',
    author_avatar_url: 'http://exercism.test/image',
    by_student: false,
    content_html: '<p>Hello</p>',
    updated_at: new Date().toISOString(),
    links: {
      self: 'https://exercism.test/links/1',
    },
  }

  const { queryByText } = render(<DiscussionPost {...post} />)

  expect(queryByText('Student')).not.toBeInTheDocument()
})
