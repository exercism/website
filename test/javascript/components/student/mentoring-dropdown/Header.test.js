import React from 'react'
import { render, screen } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { Header } from '../../../../../app/javascript/components/student/mentoring-dropdown/Header'

test('renders discussion in progress', async () => {
  render(<Header hasMentorDiscussionInProgress={true} />)

  expect(
    screen.getByText('Mentoring currently in progress')
  ).toBeInTheDocument()
})

test('renders share link', async () => {
  render(<Header hasMentorDiscussionInProgress={false} shareLink="sharelink" />)

  expect(
    screen.getByText('Want to get mentored by a friend?')
  ).toBeInTheDocument()
  expect(screen.getByText('sharelink')).toBeInTheDocument()
})
