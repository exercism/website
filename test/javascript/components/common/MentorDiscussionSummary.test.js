import React from 'react'
import { render, screen } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { MentorDiscussionSummary } from '../../../../app/javascript/components/common/MentorDiscussionSummary'

test('renders in progress tag when discussion is not finished', () => {
  const discussion = {
    isFinished: false,
    mentor: {},
    links: {},
  }

  render(<MentorDiscussionSummary {...discussion} />)

  expect(screen.getByText('In Progress')).toBeInTheDocument()
})

test('does not render in progress tag when discussion is finished', () => {
  const discussion = {
    isFinished: true,
    mentor: {},
    links: {},
  }

  render(<MentorDiscussionSummary {...discussion} />)

  expect(screen.queryByText('In Progress')).not.toBeInTheDocument()
})
