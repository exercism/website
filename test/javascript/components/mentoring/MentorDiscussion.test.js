import React from 'react'
import userEvent from '@testing-library/user-event'
import { render, screen } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { MentorDiscussion } from '../../../../app/javascript/components/mentoring/MentorDiscussion'

test('highlights currently selected iteration', async () => {
  const links = {
    scratchpad: 'https://exercism.test/scratchpad',
  }
  const iterations = [
    {
      idx: 1,
      links: {
        posts: 'https://exercism.test/iterations/1/posts',
      },
    },
    {
      idx: 2,
      links: {
        posts: 'https://exercism.test/iterations/2/posts',
      },
    },
  ]
  render(
    <MentorDiscussion links={links} iterations={iterations} discussionId={1} />
  )

  userEvent.click(screen.getByRole('button', { name: 'Go to iteration 1' }))

  expect(
    await screen.findByRole('button', { name: 'Go to iteration 1' })
  ).toHaveAttribute('aria-current', 'true')
})
