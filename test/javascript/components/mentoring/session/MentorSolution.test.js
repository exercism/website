import React from 'react'
import { render, screen } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { MentorSolution } from '../../../../../app/javascript/components/mentoring/session/MentorSolution'

test('shows CTA to contribute notes when notes isnt present', async () => {
  const solution = {
    mentor: {
      handle: 'handle',
      avatarUrl: 'url',
    },
  }
  const exercise = { title: 'Exercise' }
  const track = { title: 'Track' }

  render(
    <MentorSolution solution={solution} exercise={exercise} track={track} />
  )

  expect(
    screen.queryByAltText('Number of times solution has been starred')
  ).not.toBeInTheDocument()
})
