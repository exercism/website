import React from 'react'
import { render, screen } from '@testing-library/react'
import { rest } from 'msw'
import { setupServer } from 'msw/node'
import '@testing-library/jest-dom/extend-expect'
import { Notifications } from '../../../../app/javascript/components/dropdowns/Notifications'
import { TestQueryCache } from '../../support/TestQueryCache'
import { silenceConsole } from '../../support/silence-console'
import userEvent from '@testing-library/user-event'

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
      <Notifications endpoint="https://exercism.test/notifications" />
    </TestQueryCache>
  )
  userEvent.click(screen.getByRole('button', { name: 'Open notifications' }))

  expect(await screen.findByText('Unable to load')).toBeInTheDocument()

  server.close()
})

test('shows generic error message', async () => {
  silenceConsole()

  render(
    <TestQueryCache>
      <Notifications endpoint="https://exercism.test/notifications" />
    </TestQueryCache>
  )
  userEvent.click(screen.getByRole('button', { name: 'Open notifications' }))

  expect(
    await screen.findByText('Unable to load notifications')
  ).toBeInTheDocument()
})
