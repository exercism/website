import React from 'react'
import { screen, waitFor } from '@testing-library/react'
import { render } from '../../../test-utils'
import userEvent from '@testing-library/user-event'
import '@testing-library/jest-dom/extend-expect'
import { ResetTrackModal } from '../../../../../app/javascript/components/dropdowns/track-menu/ResetTrackModal'
import { createTrack } from '../../../factories/TrackFactory'
import { rest } from 'msw'
import { setupServer } from 'msw/node'
import { expectConsoleError } from '../../../support/silence-console'
import { redirectTo } from '../../../../../app/javascript/utils/redirect-to'

jest.mock('../../../../../app/javascript/utils/redirect-to')

const server = setupServer(
  rest.patch('https://exercism.test/tracks/ruby/reset', (req, res, ctx) => {
    return res(ctx.status(200), ctx.json({ userTrack: { links: {} } }))
  })
)

beforeAll(() => server.listen())
beforeEach(() => server.resetHandlers())
afterAll(() => server.close())

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
  expect(cancelButton).toBeDisabled()

  await waitFor(() => expect(redirectTo).toHaveBeenCalled())
})

test('user sees error messages', async () => {
  await expectConsoleError(async () => {
    server.use(
      rest.patch('https://exercism.test/tracks/ruby/reset', (req, res, ctx) => {
        return res(
          ctx.status(422),
          ctx.json({ error: { message: 'Unable to reset' } })
        )
      })
    )

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

    expect(await screen.findByText('Unable to reset')).toBeInTheDocument()
  })
})

test('user sees generic error message', async () => {
  await expectConsoleError(async () => {
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

    expect(await screen.findByText('Unable to reset track')).toBeInTheDocument()
  })
})
