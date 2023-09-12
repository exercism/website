import React from 'react'
import { screen, waitFor, act } from '@testing-library/react'
import { render } from '../../test-utils'
import '@testing-library/jest-dom/extend-expect'
import { default as TrackMenu } from '@/components/dropdowns/TrackMenu'
import userEvent from '@testing-library/user-event'
import { createTrack } from '../../factories/TrackFactory'

test('closes reset button modal when clicking on cancel', async () => {
  render(
    <TrackMenu
      track={createTrack()}
      links={{
        repo: 'something',
        documentation: 'something',
        activateLearningMode: 'something',
        activatePracticeMode: 'something',
        reset: 'something',
        leave: 'something',
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

test('closes leave modal when clicking on cancel', async () => {
  render(
    <TrackMenu
      track={createTrack()}
      links={{
        repo: 'something',
        documentation: 'something',
        activateLearningMode: 'something',
        activatePracticeMode: 'something',
        reset: 'something',
        leave: 'something',
      }}
      ariaHideApp={false}
    />
  )

  const menuButton = screen.getByRole('button')
  act(() => userEvent.click(menuButton))
  await act(async () =>
    userEvent.click(await screen.findByRole('button', { name: /Leave track…/ }))
  )
  await act(async () =>
    userEvent.click(await screen.findByRole('button', { name: 'Cancel' }))
  )

  await waitFor(() =>
    expect(screen.queryByRole('dialog')).not.toBeInTheDocument()
  )
})
test('closes leave modal when clicking on cancel in the leave + reset form', async () => {
  render(
    <TrackMenu
      track={createTrack()}
      links={{
        repo: 'something',
        documentation: 'something',
        activateLearningMode: 'something',
        activatePracticeMode: 'something',
        reset: 'something',
        leave: 'something',
      }}
      ariaHideApp={false}
    />
  )

  const menuButton = screen.getByRole('button')
  act(() => userEvent.click(menuButton))
  await act(async () =>
    userEvent.click(await screen.findByRole('button', { name: /Leave track…/ }))
  )
  await act(async () =>
    userEvent.click(await screen.findByRole('tab', { name: 'Leave + Reset' }))
  )
  await act(async () =>
    userEvent.click(await screen.findByRole('button', { name: 'Cancel' }))
  )

  await waitFor(() =>
    expect(screen.queryByRole('dialog')).not.toBeInTheDocument()
  )
})
