import * as React from 'react'

import { render, fireEvent, act, screen, within } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'

import { TrackSwitcher } from '../../../../../app/javascript/components/profile/contributions-summary/TrackSwitcher'

import {
  createTrack,
  totalTrackReputation,
} from '../../../factories/ContributionSummaryFactory'

const setup = () => {
  const tracks = [
    createTrack(),
    createTrack({
      id: 'elixir',
      title: 'Elixir',
      iconUrl: '/icons/elixir.svg',
    }),
  ]

  return {
    tracks,
  }
}

describe('TrackSwitcher', () => {
  test('shows value on render', () => {
    const { tracks } = setup()

    const currentTrack = tracks[0]

    render(
      <TrackSwitcher tracks={tracks} value={currentTrack} setValue={() => {}} />
    )

    screen.getByAltText(`icon for ${currentTrack.title} track`)
    screen.getByText(currentTrack.title)
    screen.getByText(`${totalTrackReputation(currentTrack)} rep`)
  })

  test('shows dropdown on click', async () => {
    const { tracks } = setup()

    const currentTrack = tracks[0]

    render(
      <TrackSwitcher tracks={tracks} value={currentTrack} setValue={() => {}} />
    )

    const button = screen.getByLabelText('Open the track switcher')

    await act(async () => {
      await fireEvent.click(button)
    })

    const menu = screen.getByRole('menu')
    const menuItems = within(menu).queryAllByRole('menuitem')
    expect(menuItems).toHaveLength(tracks.length)
    menuItems.forEach((menuItem, index) => {
      within(menuItem).getByAltText(`icon for ${tracks[index].title} track`)
      within(menuItem).getByText(tracks[index].title)
    })
  })
})
