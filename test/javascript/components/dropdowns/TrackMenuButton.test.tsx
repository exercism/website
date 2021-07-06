import React from 'react'
import { render, screen, waitFor, act } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { TrackMenu } from '../../../../app/javascript/components/dropdowns/TrackMenu'
import userEvent from '@testing-library/user-event'
import { createTrack } from '../../factories/TrackFactory'

test('closes reset button modal when clicking on cancel', async () => {
  render(
    <TrackMenu
      track={createTrack()}
      links={{
        repo: '',
        documentation: '',
        activateLearningMode: '',
        activatePracticeMode: '',
        reset: '',
        leave: '',
      }}
      ariaHideApp={false}
    />
  )

  const menuButton = screen.getByRole('button')
  act(() => userEvent.click(menuButton))
  await act(async () =>
    userEvent.click(await screen.findByRole('button', { name: 'Reset track…' }))
  )
  await act(async () =>
    userEvent.click(await screen.findByRole('button', { name: 'Cancel' }))
  )

  await waitFor(() =>
    expect(screen.queryByRole('dialog')).not.toBeInTheDocument()
  )
})
