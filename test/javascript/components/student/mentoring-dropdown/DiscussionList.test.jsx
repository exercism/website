import React from 'react'
import { render, screen } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { DiscussionList } from '../../../../../app/javascript/components/student/mentoring-dropdown/DiscussionList'

test('renders zero state', async () => {
  render(<DiscussionList discussions={[]} />)

  expect(
    screen.getByText(
      'Your code review discussions with mentors for this exercise will appear here once started.'
    )
  ).toBeInTheDocument()
})

test('renders discussions', async () => {
  const discussions = [
    {
      uuid: 'uuid',
      mentor: {},
      links: {
        self: 'https://exercism.test/discussion',
      },
    },
  ]
  render(<DiscussionList discussions={discussions} />)

  expect(screen.getByRole('link')).toHaveAttribute(
    'href',
    'https://exercism.test/discussion'
  )
})
