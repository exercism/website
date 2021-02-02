import React from 'react'
import { render, screen } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { MentorNotes } from '../../../../../app/javascript/components/mentoring/discussion/MentorNotes'

test('shows CTA to contribute notes when notes isnt present', async () => {
  render(<MentorNotes />)

  expect(screen.getByText('CTA to contribute notes here')).toBeInTheDocument()
})

test('shows CTA to improve notes when notes is present', async () => {
  render(<MentorNotes notes="<p>Notes</p>" />)

  expect(screen.getByText('CTA to improve notes here')).toBeInTheDocument()
})
