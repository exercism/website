import React from 'react'
import { screen, render, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import '@testing-library/jest-dom/extend-expect'
import { ResetTrackModal } from '../../../../../app/javascript/components/dropdowns/track-menu/ResetTrackModal'
import { createTrack } from '../../../factories/TrackFactory'
import { rest } from 'msw'
import { setupServer } from 'msw/node'
import { silenceConsole } from '../../../support/silence-console'

test('form is disabled when confirmation is wrong', async () => {
  render(
    <ResetTrackModal
      open
      onClose={jest.fn()}
      track={createTrack({ slug: 'ruby' })}
      endpoint=""
      ariaHideApp={false}
    />
  )

  userEvent.type(
    screen.getByLabelText('To confirm, write reset ruby in the box below:'),
    'wrong'
  )

  expect(screen.getByRole('button', { name: 'Reset track' })).toBeDisabled()
})

test('form is enabled when confirmation is correct', async () => {
  render(
    <ResetTrackModal
      open
      onClose={jest.fn()}
      track={createTrack({ slug: 'ruby' })}
      endpoint=""
      ariaHideApp={false}
    />
  )

  userEvent.type(
    screen.getByLabelText('To confirm, write reset ruby in the box below:'),
    'reset ruby'
  )

  expect(screen.getByRole('button', { name: 'Reset track' })).not.toBeDisabled()
})

test('buttons are disabled while waiting for response', async () => {
  Object.defineProperty(window, 'location', {
    writable: true,
    value: { replace: jest.fn() },
  })
  const server = setupServer(
    rest.patch('https://exercism.test/tracks/ruby/reset', (req, res, ctx) => {
      return res(ctx.status(200), ctx.json({ userTrack: { links: {} } }))
    })
  )
  server.listen()

  render(
    <ResetTrackModal
      open
      onClose={jest.fn()}
      track={createTrack({ slug: 'ruby' })}
      endpoint="https://exercism.test/tracks/ruby/reset"
      ariaHideApp={false}
    />
  )

  const resetButton = screen.getByRole('button', { name: 'Reset track' })
  const cancelButton = screen.getByRole('button', { name: 'Cancel' })

  userEvent.type(
    screen.getByLabelText('To confirm, write reset ruby in the box below:'),
    'reset ruby'
  )
  userEvent.click(resetButton)

  await waitFor(() => expect(resetButton).toBeDisabled())
  await waitFor(() => expect(cancelButton).toBeDisabled())

  server.close()
})

test('user sees error messages', async () => {
  silenceConsole()

  const server = setupServer(
    rest.patch('https://exercism.test/tracks/ruby/reset', (req, res, ctx) => {
      return res(
        ctx.status(422),
        ctx.json({ error: { message: 'Unable to reset' } })
      )
    })
  )
  server.listen()

  render(
    <ResetTrackModal
      open
      onClose={jest.fn()}
      track={createTrack({ slug: 'ruby' })}
      endpoint="https://exercism.test/tracks/ruby/reset"
      ariaHideApp={false}
    />
  )

  const resetButton = screen.getByRole('button', { name: 'Reset track' })

  userEvent.type(
    screen.getByLabelText('To confirm, write reset ruby in the box below:'),
    'reset ruby'
  )
  userEvent.click(resetButton)

  await waitFor(() =>
    expect(screen.getByText('Unable to reset')).toBeInTheDocument()
  )

  server.close()
})

test('user sees generic error message', async () => {
  silenceConsole()

  render(
    <ResetTrackModal
      open
      onClose={jest.fn()}
      track={createTrack({ slug: 'ruby' })}
      endpoint="wrongendpoint"
      ariaHideApp={false}
    />
  )

  const resetButton = screen.getByRole('button', { name: 'Reset track' })
  userEvent.type(
    screen.getByLabelText('To confirm, write reset ruby in the box below:'),
    'reset ruby'
  )
  userEvent.click(resetButton)

  await waitFor(() =>
    expect(screen.getByText('Unable to reset track')).toBeInTheDocument()
  )
})
