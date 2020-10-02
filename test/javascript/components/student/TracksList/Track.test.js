import React from 'react'
import { render, fireEvent } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { Track } from '../../../../../app/javascript/components/student/tracks-list/Track'

test('hides progress bar if track is unjoined', () => {
  const { queryByTestId } = render(
    <Track track={{ isJoined: false, isNew: false, tags: [] }} />
  )

  expect(queryByTestId('track-progress-bar')).not.toBeInTheDocument()
})

test('hides joined status if track is unjoined', () => {
  const { queryByText } = render(
    <Track track={{ isJoined: false, isNew: false, tags: [] }} />
  )

  expect(queryByText('Joined')).not.toBeInTheDocument()
})
