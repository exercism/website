import React from 'react'
import userEvent from '@testing-library/user-event'
import { render, screen } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { TrackFilterList } from '../../../../../app/javascript/components/mentoring/queue/TrackFilterList'
import { QueryStatus } from '@tanstack/react-query'
import { TestQueryCache } from '../../../support/TestQueryCache'
import { queryClient } from '../../../setupTests'

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
    <TestQueryCache queryClient={queryClient}>
      <TrackFilterList
        cacheKey={['CACHE_KEY']}
        status={'success' as QueryStatus}
        error={null}
        tracks={tracks}
        isFetching={false}
        value={{
          slug: 'csharp',
          title: 'C#',
          iconUrl: 'https://exercism.test/tracks/csharp/icon',
          numSolutionsQueued: 2,
          exercises: [],
          links: {
            exercises: 'https://exercism.test/tracks/csharp/exercises',
          },
        }}
        setValue={() => null}
        links={{
          tracks: 'https://exercism.test/tracks',
          updateTracks: 'https://exercism.test/tracks',
        }}
      />
    </TestQueryCache>
  )

  userEvent.click(screen.getByRole('button', { name: 'Open the track filter' }))
  userEvent.click(
    await screen.findByRole('radio', { name: 'icon for Ruby track Ruby 2' })
  )

  expect(screen.queryByRole('menu')).not.toBeInTheDocument()
})
