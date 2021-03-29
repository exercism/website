import React from 'react'
import { render, screen } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { CommunitySolution } from '../../../../app/javascript/components/common/CommunitySolution'

test('shows CTA to contribute notes when notes isnt present', async () => {
  const solution = {
    author: {
      handle: 'handle',
      avatarUrl: 'url',
    },
    links: {
      publicUrl: 'https://google.com',
    },
  }
  const exercise = { title: 'Exercise' }
  const track = { title: 'Track' }

  render(
    <CommunitySolution solution={solution} exercise={exercise} track={track} />
  )

  expect(
    screen.queryByAltText('Number of times solution has been starred')
  ).not.toBeInTheDocument()
})
