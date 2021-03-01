import React from 'react'
import { render, screen } from '@testing-library/react'
import { rest } from 'msw'
import { setupServer } from 'msw/node'
import '@testing-library/jest-dom/extend-expect'
import { MarkAsNothingToDoButton } from '../../../../../app/javascript/components/mentoring/discussion/MarkAsNothingToDoButton'
import { expectConsoleError } from '../../../support/silence-console'
import userEvent from '@testing-library/user-event'
import { TestQueryCache } from '../../../support/TestQueryCache'

test('shows errors from API', async () => {
  expectConsoleError(async () => {
    const server = setupServer(
      rest.patch('https://exercism.test/action', (req, res, ctx) => {
        return res(
          ctx.delay(10),
          ctx.status(422),
          ctx.json({ error: { message: 'Unable to run action' } })
        )
      })
    )
    server.listen()

    render(
      <TestQueryCache>
        <MarkAsNothingToDoButton endpoint="https://exercism.test/action" />
      </TestQueryCache>
    )

    userEvent.click(
      screen.getByRole('button', { name: 'Mark as nothing to do' })
    )

    expect(await screen.findByText('Unable to run action')).toBeInTheDocument()
    expect(
      await screen.findByRole('button', { name: 'Mark as nothing to do' })
    ).toBeInTheDocument()

    queryCache.cancelQueries()
    server.close()
  })
})

test('shows generic error message for unexpected errors', async () => {
  expectConsoleError(async () => {
    render(<MarkAsNothingToDoButton endpoint="wrong" />)

    userEvent.click(
      screen.getByRole('button', { name: 'Mark as nothing to do' })
    )

    expect(
      await screen.findByText('Unable to mark discussion as nothing to do')
    ).toBeInTheDocument()
    expect(
      await screen.findByRole('button', { name: 'Mark as nothing to do' })
    ).toBeInTheDocument()
  })
})
