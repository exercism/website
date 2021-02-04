import React from 'react'
import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { rest } from 'msw'
import { setupServer } from 'msw/node'
import '@testing-library/jest-dom/extend-expect'
import { AboutToEndSession } from '../../../../../app/javascript/components/modals/end-session-modal/AboutToEndSession'
import { silenceConsole } from '../../../support/silence-console'

test('disables buttons when loading', async () => {
  const server = setupServer(
    rest.patch('https://exercism.test/end', (req, res, ctx) => {
      return res(ctx.status(200), ctx.json({ discussion: {} }))
    })
  )
  server.listen()

  render(<AboutToEndSession endpoint="https://exercism.test/end" />)
  userEvent.click(screen.getByRole('button', { name: 'End session' }))

  expect(
    await screen.findByRole('button', { name: 'End session' })
  ).toBeDisabled()
  expect(screen.getByRole('button', { name: 'Cancel' })).toBeDisabled()

  server.close()
})

test('shows loading message when loading', async () => {
  const server = setupServer(
    rest.patch('https://exercism.test/end', (req, res, ctx) => {
      return res(ctx.status(200), ctx.json({ discussion: {} }))
    })
  )
  server.listen()

  render(<AboutToEndSession endpoint="https://exercism.test/end" />)
  userEvent.click(screen.getByRole('button', { name: 'End session' }))

  expect(await screen.findByText('Loading')).toBeInTheDocument()

  server.close()
})

test('shows API errors', async () => {
  silenceConsole()
  const server = setupServer(
    rest.patch('https://exercism.test/end', (req, res, ctx) => {
      return res(
        ctx.status(422),
        ctx.json({ error: { message: 'Unable to end discussion' } })
      )
    })
  )
  server.listen()

  render(<AboutToEndSession endpoint="https://exercism.test/end" />)
  userEvent.click(screen.getByRole('button', { name: 'End session' }))

  expect(
    await screen.findByText('Unable to end discussion')
  ).toBeInTheDocument()

  server.close()
})

test('shows generic error', async () => {
  silenceConsole()

  render(<AboutToEndSession endpoint="weirdendpoint" />)
  userEvent.click(screen.getByRole('button', { name: 'End session' }))

  expect(
    await screen.findByText('Unable to end discussion')
  ).toBeInTheDocument()
})
