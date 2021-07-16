import React from 'react'
import { screen, render, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import '@testing-library/jest-dom/extend-expect'
import { LeaveResetTrackForm } from '../../../../../../app/javascript/components/dropdowns/track-menu/leave-track-modal/LeaveResetTrackForm'
import { createTrack } from '../../../../factories/TrackFactory'
import { rest } from 'msw'
import { setupServer } from 'msw/node'
import { silenceConsole } from '../../../../support/silence-console'

test('form is disabled when confirmation is wrong', async () => {
  render(
    <LeaveResetTrackForm
      track={createTrack({ slug: 'ruby' })}
      endpoint=""
      onCancel={jest.fn()}
    />
  )

  userEvent.type(
    screen.getByLabelText('To confirm, write reset ruby in the box below:'),
    'wrong'
  )

  expect(screen.getByRole('button', { name: 'Leave + Reset' })).toBeDisabled()
})

test('form is enabled when confirmation is correct', async () => {
  render(
    <LeaveResetTrackForm
      track={createTrack({ slug: 'ruby' })}
      endpoint=""
      onCancel={jest.fn()}
    />
  )

  userEvent.type(
    screen.getByLabelText('To confirm, write reset ruby in the box below:'),
    'reset ruby'
  )

  expect(
    screen.getByRole('button', { name: 'Leave + Reset' })
  ).not.toBeDisabled()
})

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
    <LeaveResetTrackForm
      track={createTrack({ slug: 'ruby' })}
      endpoint="https://exercism.test/tracks/ruby/leave"
      onCancel={jest.fn()}
    />
  )

  const leaveButton = screen.getByRole('button', { name: 'Leave + Reset' })
  const cancelButton = screen.getByRole('button', { name: 'Cancel' })

  userEvent.type(
    screen.getByLabelText('To confirm, write reset ruby in the box below:'),
    'reset ruby'
  )

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
    <LeaveResetTrackForm
      track={createTrack({ slug: 'ruby' })}
      endpoint="https://exercism.test/tracks/ruby/leave"
      onCancel={jest.fn()}
    />
  )

  userEvent.type(
    screen.getByLabelText('To confirm, write reset ruby in the box below:'),
    'reset ruby'
  )

  userEvent.click(screen.getByRole('button', { name: 'Leave + Reset' }))

  await waitFor(() =>
    expect(screen.getByText('Unable to leave')).toBeInTheDocument()
  )

  server.close()
})

test('user sees generic error message', async () => {
  silenceConsole()

  render(
    <LeaveResetTrackForm
      track={createTrack({ slug: 'ruby' })}
      endpoint="wrongendpoint"
      onCancel={jest.fn()}
    />
  )

  userEvent.type(
    screen.getByLabelText('To confirm, write reset ruby in the box below:'),
    'reset ruby'
  )

  userEvent.click(screen.getByRole('button', { name: 'Leave + Reset' }))

  await waitFor(() =>
    expect(
      screen.getByText('Unable to leave and reset track')
    ).toBeInTheDocument()
  )
})
