import React from 'react'
import { render, screen } from '@testing-library/react'
import { rest } from 'msw'
import { setupServer } from 'msw/node'
import '@testing-library/jest-dom/extend-expect'
import { default as Notifications } from '@/components/dropdowns/Notifications'
import { TestQueryCache } from '../../support/TestQueryCache'
import { expectConsoleError } from '../../support/silence-console'
import userEvent from '@testing-library/user-event'
import { queryClient } from '../../setupTests'

test('shows API error message', async () => {
  expectConsoleError(async () => {
    const server = setupServer(
      rest.get('https://exercism.test/notifications', (req, res, ctx) => {
        return res(
          ctx.delay(10),
          ctx.status(422),
          ctx.json({
            error: { message: 'Unable to load' },
          })
        )
      })
    )
    server.listen()

    render(
      <TestQueryCache queryClient={queryClient}>
        <Notifications endpoint="https://exercism.test/notifications" />
      </TestQueryCache>
    )
    userEvent.click(
      await screen.findByRole('button', { name: 'Open notifications' })
    )

    expect(await screen.findByText('Unable to load')).toBeInTheDocument()

    server.close()
  })
})

test('shows generic error message', async () => {
  expectConsoleError(async () => {
    render(
      <TestQueryCache queryClient={queryClient}>
        <Notifications endpoint="https://exercism.test/notifications" />
      </TestQueryCache>
    )
    userEvent.click(
      await screen.findByRole('button', { name: 'Open notifications' })
    )

    expect(
      await screen.findByText('Unable to load notifications')
    ).toBeInTheDocument()
  })
})
