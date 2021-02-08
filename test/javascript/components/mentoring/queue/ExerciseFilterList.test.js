import React from 'react'
import userEvent from '@testing-library/user-event'
import { render, screen } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { ExerciseFilterList } from '../../../../../app/javascript/components/mentoring/queue/ExerciseFilterList'

test('searches for exercises', async () => {
  const exercises = [
    { slug: 'tournament', title: 'Tournament' },
    { slug: 'series', title: 'Series' },
  ]

  render(<ExerciseFilterList exercises={exercises} value={[]} />)

  userEvent.type(screen.getByRole('textbox'), 'tour')

  expect(
    await screen.findByRole('checkbox', { name: 'Tournament' })
  ).toBeInTheDocument()
  expect(
    screen.queryByRole('checkbox', { name: 'Series' })
  ).not.toBeInTheDocument()
})
