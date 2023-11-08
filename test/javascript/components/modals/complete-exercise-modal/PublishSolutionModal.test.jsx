import React from 'react'
import { screen, waitFor } from '@testing-library/react'
import { render } from '../../../test-utils'
import userEvent from '@testing-library/user-event'
import { rest } from 'msw'
import { setupServer } from 'msw/node'
import '@testing-library/jest-dom/extend-expect'
import { PublishSolutionModal } from '../../../../../app/javascript/components/modals/complete-exercise-modal/PublishSolutionModal'
import { expectConsoleError } from '../../../support/silence-console'

jest.mock('../../../../../app/javascript/utils/redirect-to')

const server = setupServer(
  rest.patch('https://exercism.test/publish', (req, res, ctx) => {
    return res(ctx.status(200), ctx.json({ solution: {} }))
  })
)

beforeAll(() => server.listen())
beforeEach(() => server.resetHandlers())
afterAll(() => server.close())

test('shows loading status', async () => {
  const handleSuccess = jest.fn()
  render(
    <PublishSolutionModal
      endpoint="https://exercism.test/publish"
      open={true}
      ariaHideApp={false}
      onSuccess={handleSuccess}
    />
  )
  userEvent.click(await screen.findByRole('button', { name: 'Confirm' }))

  expect(await screen.findByText('Loading')).toBeInTheDocument()

  await waitFor(() => expect(handleSuccess).toHaveBeenCalled())
})

test('shows errors', async () => {
  await expectConsoleError(async () => {
    server.use(
      rest.patch('https://exercism.test/publish', (req, res, ctx) => {
        return res(
          ctx.status(422),
          ctx.json({
            error: {
              message: 'Unable to complete exercise',
            },
          })
        )
      })
    )

    render(
      <PublishSolutionModal
        endpoint="https://exercism.test/publish"
        open={true}
        ariaHideApp={false}
        onSuccess={() => null}
      />
    )
    userEvent.click(screen.getByRole('button', { name: 'Confirm' }))

    expect(
      await screen.findByText('Unable to complete exercise')
    ).toBeInTheDocument()
  })
})

test('shows generic errors', async () => {
  await expectConsoleError(async () => {
    render(
      <PublishSolutionModal
        endpoint="weirdendpoint"
        open={true}
        ariaHideApp={false}
        onSuccess={() => null}
      />
    )
    userEvent.click(screen.getByRole('button', { name: 'Confirm' }))

    expect(
      await screen.findByText('Unable to complete exercise')
    ).toBeInTheDocument()
  })
})
