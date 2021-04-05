import React from 'react'
import userEvent from '@testing-library/user-event'
import { render, screen } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { TrackList } from '../../../../../app/javascript/components/mentoring/inbox/TrackList'

test('closes dropdown after choosing a track', async () => {
  const tracks = [
    {
      slug: 'ruby',
      title: 'Ruby',
      iconUrl: 'https://exercism.test/tracks/ruby/icon',
      count: 2,
    },
    {
      slug: 'csharp',
      title: 'C#',
      iconUrl: 'https://exercism.test/tracks/csharp/icon',
      count: 2,
    },
  ]

  render(<TrackList tracks={tracks} value={null} setTrack={() => null} />)

  userEvent.click(
    screen.getByRole('button', { name: 'Button to open the track filter' })
  )
  userEvent.click(
    await screen.findByRole('radio', { name: 'icon for Ruby track Ruby 2' })
  )

  expect(screen.queryByRole('menu')).not.toBeInTheDocument()
})
