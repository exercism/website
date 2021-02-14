import React from 'react'
import { render, screen } from '@testing-library/react'
import { rest } from 'msw'
import { setupServer } from 'msw/node'
import '@testing-library/jest-dom/extend-expect'
import { NotificationsMenu } from '../../../../../app/javascript/components/dropdowns/notifications/NotificationsMenu'
import { TestQueryCache } from '../../../support/TestQueryCache'
import { silenceConsole } from '../../../support/silence-console'

test('shows loading message', async () => {
  const server = setupServer(
    rest.get('https://exercism.test/notifications', (req, res, ctx) => {
      return res(ctx.status(200))
    })
  )
  server.listen()

  render(<NotificationsMenu endpoint="https://exercism.test/notifications" />)

  expect(screen.getByText('Loading')).toBeInTheDocument()

  server.close()
})

test('shows API error message', async () => {
  silenceConsole()
  const server = setupServer(
    rest.get('https://exercism.test/notifications', (req, res, ctx) => {
      return res(
        ctx.status(422),
        ctx.json({
          error: { message: 'Unable to load' },
        })
      )
    })
  )
  server.listen()

  render(
    <TestQueryCache>
      <NotificationsMenu endpoint="https://exercism.test/notifications" />
    </TestQueryCache>
  )

  expect(await screen.findByText('Unable to load')).toBeInTheDocument()

  server.close()
})

test('shows generic error message', async () => {
  silenceConsole()

  render(
    <TestQueryCache>
      <NotificationsMenu endpoint="weirdendpoint" />
    </TestQueryCache>
  )

  expect(
    await screen.findByText('Unable to load notifications')
  ).toBeInTheDocument()
})
