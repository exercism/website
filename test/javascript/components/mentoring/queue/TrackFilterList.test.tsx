import React from 'react'
import userEvent from '@testing-library/user-event'
import { render, screen } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { TrackFilterList } from '../../../../../app/javascript/components/mentoring/queue/TrackFilterList'
import { QueryStatus } from 'react-query'

test('closes dropdown after choosing a track', async () => {
  const tracks = [
    {
      id: 'ruby',
      iconUrl: 'https://exercism.test/tracks/ruby/icon',
      numSolutionsQueued: 2,
      exercises: [],
      slug: 'ruby',
      title: 'Ruby',
      links: {
        exercises: 'https://exercism.test/tracks/ruby/exercises',
      },
    },
    {
      id: 'csharp',
      iconUrl: 'https://exercism.test/tracks/csharp/icon',
      numSolutionsQueued: 2,
      exercises: [],
      slug: 'csharp',
      title: 'C#',
      links: {
        exercises: 'https://exercism.test/tracks/csharp/exercises',
      },
    },
  ]

  render(
    <TrackFilterList
      cacheKey="CACHE_KEY"
      status={'success' as QueryStatus}
      error={null}
      tracks={tracks}
      isFetching={false}
      value={null}
      setValue={() => null}
      links={{
        tracks: 'https://exercism.test/tracks',
        updateTracks: 'https://exercism.test/tracks',
      }}
    />
  )

  userEvent.click(
    screen.getByRole('button', { name: 'Button to open the track filter' })
  )
  userEvent.click(
    await screen.findByRole('radio', { name: 'icon for Ruby track Ruby 2' })
  )

  expect(screen.queryByRole('menu')).not.toBeInTheDocument()
})
