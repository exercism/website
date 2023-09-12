import React from 'react'
import { screen, waitFor } from '@testing-library/react'
import { render } from '../../../../test-utils'
import userEvent from '@testing-library/user-event'
import '@testing-library/jest-dom/extend-expect'
import { LeaveResetTrackForm } from '../../../../../../app/javascript/components/dropdowns/track-menu/leave-track-modal/LeaveResetTrackForm'
import { createTrack } from '../../../../factories/TrackFactory'
import { rest } from 'msw'
import { setupServer } from 'msw/node'
import { expectConsoleError } from '../../../../support/silence-console'
import { redirectTo } from '../../../../../../app/javascript/utils/redirect-to'

jest.mock('../../../../../../app/javascript/utils/redirect-to')

const server = setupServer(
  rest.patch('https://exercism.test/tracks/ruby/leave', (req, res, ctx) => {
    return res(
      ctx.delay(10),
      ctx.status(200),
      ctx.json({ userTrack: { links: {} } })
    )
  })
)

beforeAll(() => server.listen())
beforeEach(() => server.resetHandlers())
afterAll(() => server.close())

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
  await waitFor(() => expect(redirectTo).toHaveBeenCalled())
})

test('user sees error messages', async () => {
  await expectConsoleError(async () => {
    server.use(
      rest.patch('https://exercism.test/tracks/ruby/leave', (req, res, ctx) => {
        return res(
          ctx.delay(10),
          ctx.status(422),
          ctx.json({ error: { message: 'Unable to leave' } })
        )
      })
    )

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

    expect(await screen.findByText('Unable to leave')).toBeInTheDocument()
  })
})

test('user sees generic error message', async () => {
  await expectConsoleError(async () => {
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

    expect(
      await screen.findByText('Unable to leave and reset track')
    ).toBeInTheDocument()
  })
})
