import React from 'react'
import { screen, waitFor } from '@testing-library/react'
import { render } from '../../../../test-utils'
import userEvent from '@testing-library/user-event'
import '@testing-library/jest-dom/extend-expect'
import { LeaveTrackForm } from '../../../../../../app/javascript/components/dropdowns/track-menu/leave-track-modal/LeaveTrackForm'
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

test('buttons are disabled while waiting for response', async () => {
  const mockedRedirectTo = redirectTo as jest.Mock

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
  await waitFor(() => expect(mockedRedirectTo).toHaveBeenCalled())
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
  })
})

test('user sees generic error message', async () => {
  await expectConsoleError(async () => {
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
})
