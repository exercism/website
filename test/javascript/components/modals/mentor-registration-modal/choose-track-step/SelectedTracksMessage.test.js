import React from 'react'
import { render, screen } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { SelectedTracksMessage } from '../../../../../../app/javascript/components/modals/mentor-registration-modal/choose-track-step/SelectedTracksMessage'

test('shows message for numSelected = 0', async () => {
  render(<SelectedTracksMessage numSelected={0} />)

  expect(screen.getByText('No tracks selected')).toHaveAttribute(
    'class',
    'selected none'
  )
})

test('shows message for numSelected = 1', async () => {
  render(<SelectedTracksMessage numSelected={1} />)

  expect(screen.getByText('1 track selected')).toHaveAttribute(
    'class',
    'selected'
  )
})
test('shows message for numSelected > 1', async () => {
  render(<SelectedTracksMessage numSelected={5} />)

  expect(screen.getByText('5 tracks selected')).toHaveAttribute(
    'class',
    'selected'
  )
})
