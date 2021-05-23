import React from 'react'
import { render, screen } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { PreviousSessionsLink } from '../../../../../app/javascript/components/mentoring/session/PreviousSessionsLink'

test('shows number of sessions', async () => {
  render(
    <PreviousSessionsLink
      student={{
        numDiscussionsWithMentor: 10,
        links: { previousSessions: '' },
      }}
    />
  )

  expect(screen.getByText('See 9 previous sessions')).toBeInTheDocument()
})

test('shows nothing when sessions = 0', async () => {
  render(<PreviousSessionsLink student={{ numDiscussionsWithMentor: 1 }} />)

  expect(screen.queryByText('See 0 previous sessions')).not.toBeInTheDocument()
})
