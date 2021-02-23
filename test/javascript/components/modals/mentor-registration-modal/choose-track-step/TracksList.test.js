import React from 'react'
import { render, screen } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { TracksList } from '../../../../../../app/javascript/components/modals/mentor-registration-modal/choose-track-step/TracksList'

test('shows message when no tracks have been found', async () => {
  render(<TracksList status="success" data={{ tracks: [] }} />)

  expect(screen.getByText('No tracks found')).toBeInTheDocument()
})

test('shows message when API returns nothing', async () => {
  render(<TracksList status="success" data={undefined} />)

  expect(screen.getByText('No tracks found')).toBeInTheDocument()
})
