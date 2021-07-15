import React from 'react'
import { screen, render, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import '@testing-library/jest-dom/extend-expect'
import { LeaveTrackForm } from '../../../../../../app/javascript/components/dropdowns/track-menu/leave-track-modal/LeaveTrackForm'
import { createTrack } from '../../../../factories/TrackFactory'
import { rest } from 'msw'
import { setupServer } from 'msw/node'
import { silenceConsole } from '../../../../support/silence-console'

test('buttons are disabled while waiting for response', async () => {
  Object.defineProperty(window, 'location', {
    writable: true,
    value: { replace: jest.fn() },
  })
  const server = setupServer(
    rest.patch('https://exercism.test/tracks/ruby/leave', (req, res, ctx) => {
      return res(
        ctx.delay(10),
        ctx.status(200),
        ctx.json({ userTrack: { links: {} } })
      )
    })
  )
  server.listen()

  render(
    <LeaveTrackForm
      track={createTrack({ slug: 'ruby' })}
      endpoint="https://exercism.test/tracks/ruby/leave"
      onCancel={jest.fn()}
    />
  )

  const leaveButton = screen.getByRole('button', { name: 'Leave track' })
  const cancelButton = screen.getByRole('button', { name: 'Cancel' })

  userEvent.click(leaveButton)

  await waitFor(() => expect(leaveButton).toBeDisabled())
  await waitFor(() => expect(cancelButton).toBeDisabled())

  server.close()
})

test('user sees error messages', async () => {
  silenceConsole()

  const server = setupServer(
    rest.patch('https://exercism.test/tracks/ruby/leave', (req, res, ctx) => {
      return res(
        ctx.delay(10),
        ctx.status(422),
        ctx.json({ error: { message: 'Unable to leave' } })
      )
    })
  )
  server.listen()

  render(
    <LeaveTrackForm
      track={createTrack({ slug: 'ruby' })}
      endpoint="https://exercism.test/tracks/ruby/leave"
      onCancel={jest.fn()}
    />
  )

  userEvent.click(screen.getByRole('button', { name: 'Leave track' }))

  await waitFor(() =>
    expect(screen.getByText('Unable to leave')).toBeInTheDocument()
  )

  server.close()
})

test('user sees generic error message', async () => {
  silenceConsole()

  render(
    <LeaveTrackForm
      track={createTrack({ slug: 'ruby' })}
      endpoint="wrongendpoint"
      onCancel={jest.fn()}
    />
  )

  userEvent.click(screen.getByRole('button', { name: 'Leave track' }))

  await waitFor(() =>
    expect(screen.getByText('Unable to leave track')).toBeInTheDocument()
  )
})
