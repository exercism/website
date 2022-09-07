import React from 'react'
import { render, screen } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { MentorNotes } from '../../../../../app/javascript/components/mentoring/session/MentorNotes'

test('shows CTA to contribute notes when notes isnt present', async () => {
  render(
    <MentorNotes
      improveUrl="https://exercism.org/notes"
      guidanceType="exercise"
    />
  )

  expect(
    screen.getByText(/This exercise doesn't have any mentoring notes yet/)
  ).toBeInTheDocument()
  expect(screen.getByRole('link', { name: /pull request/i })).toHaveAttribute(
    'href',
    'https://exercism.org/notes'
  )
})

test('shows CTA to improve notes when notes is present', async () => {
  render(
    <MentorNotes
      notes="<p>Mentor notes here</p>"
      guidanceType="exercise"
      improveUrl="https://exercism.org/notes"
    />
  )

  expect(screen.getByText(/Mentor notes here/)).toBeInTheDocument()
  expect(screen.getByRole('link', { name: /pull request/i })).toHaveAttribute(
    'href',
    'https://exercism.org/notes'
  )
})
