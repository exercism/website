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
    snippet: '',
    numLoc: '1-5',
    numStars: '2',
    numComments: '2',
    publishedAt: '',
    language: 'ruby',
    links: {
      publicUrl: 'https://exercism.test/public',
      privateUrl: 'https://exercism.test/private',
    },
  }
  const exercise = {
    id: 'exercise',
    title: 'Exercise',
    iconUrl: 'https://exercism.test/icon',
  }
  const track = {
    id: 'track',
    title: 'Track',
    highlightjsLanguage: 'track',
    iconUrl: 'https://exercism.test/icon',
    medianWaitTime: '5 days',
  }

  render(
    <CommunitySolution solution={solution} exercise={exercise} track={track} />
  )

  expect(
    screen.queryByAltText('Number of times solution has been starred')
  ).not.toBeInTheDocument()
})
