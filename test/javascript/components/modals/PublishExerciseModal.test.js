import React from 'react'
import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { rest } from 'msw'
import { setupServer } from 'msw/node'
import '@testing-library/jest-dom/extend-expect'
import { PublishExerciseModal } from '../../../../app/javascript/components/modals/PublishExerciseModal'
import { silenceConsole } from '../../support/silence-console'

test('shows loading status', async () => {
  const server = setupServer(
    rest.patch('https://exercism.test/publish', (req, res, ctx) => {
      return res(ctx.status(200), ctx.json({}))
    })
  )
  server.listen()

  render(
    <PublishExerciseModal
      endpoint="https://exercism.test/publish"
      open={true}
      ariaHideApp={false}
      onSuccess={() => {}}
    />
  )
  userEvent.click(screen.getByRole('button', { name: 'Confirm' }))

  expect(await screen.findByText('Loading')).toBeInTheDocument()

  server.close()
})

test('shows errors', async () => {
  silenceConsole()
  const server = setupServer(
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
  server.listen()

  render(
    <PublishExerciseModal
      endpoint="https://exercism.test/publish"
      open={true}
      ariaHideApp={false}
      onSuccess={() => {}}
    />
  )
  userEvent.click(screen.getByRole('button', { name: 'Confirm' }))

  expect(
    await screen.findByText('Unable to complete exercise')
  ).toBeInTheDocument()

  server.close()
})

test('shows generic errors', async () => {
  silenceConsole()

  render(
    <PublishExerciseModal
      endpoint="weirdendpoint"
      open={true}
      ariaHideApp={false}
      onSuccess={() => {}}
    />
  )
  userEvent.click(screen.getByRole('button', { name: 'Confirm' }))

  expect(
    await screen.findByText('Unable to complete exercise')
  ).toBeInTheDocument()
})
