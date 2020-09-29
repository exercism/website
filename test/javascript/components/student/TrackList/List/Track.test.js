import React from 'react'
import { render, fireEvent } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { Track } from '../../../../../../app/javascript/components/student/TrackList/List/Track'

test('hides progress bar if track is unjoined', () => {
  const { queryByTestId } = render(
    <table>
      <tbody>
        <Track track={{ isJoined: false, isNew: false, tags: [] }} />
      </tbody>
    </table>
  )

  expect(queryByTestId('track-progress-bar')).not.toBeInTheDocument()
})
