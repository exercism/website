import React from 'react'
import userEvent from '@testing-library/user-event'
import { render, screen } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { ExerciseFilterList } from '../../../../../app/javascript/components/mentoring/queue/ExerciseFilterList'

test('searches for exercises', async () => {
  const exercises = [
    {
      slug: 'tournament',
      title: 'Tournament',
      iconName: 'butterflies',
      count: 2,
    },
    { slug: 'series', title: 'Series', iconName: 'rocket', count: 2 },
  ]

  render(
    <ExerciseFilterList status="success" exercises={exercises} value={[]} />
  )

  userEvent.type(screen.getByRole('textbox'), 'tour')

  expect(
    await screen.findByRole('radio', { name: 'Tournament 2' })
  ).toBeInTheDocument()
  expect(
    screen.queryByRole('radio', { name: 'Series 2' })
  ).not.toBeInTheDocument()
})
