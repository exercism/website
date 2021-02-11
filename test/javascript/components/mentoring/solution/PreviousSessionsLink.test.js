import React from 'react'
import { render, screen } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { PreviousSessionsLink } from '../../../../../app/javascript/components/mentoring/solution/PreviousSessionsLink'

test('shows number of sessions', async () => {
  render(<PreviousSessionsLink numSessions={10} />)

  expect(screen.getByText('10 previous sessions')).toBeInTheDocument()
})

test('shows nothing when sessions = 0', async () => {
  render(<PreviousSessionsLink numSessions={0} />)

  expect(screen.queryByText('0 previous sessions')).not.toBeInTheDocument()
})
