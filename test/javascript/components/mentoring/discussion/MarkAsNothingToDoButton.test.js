import React from 'react'
import { render, screen } from '@testing-library/react'
import { rest } from 'msw'
import { setupServer } from 'msw/node'
import '@testing-library/jest-dom/extend-expect'
import { MarkAsNothingToDoButton } from '../../../../../app/javascript/components/mentoring/discussion/MarkAsNothingToDoButton'
import { silenceConsole } from '../../../support/silence-console'
import userEvent from '@testing-library/user-event'

test('shows errors from API', async () => {
  silenceConsole()
  const server = setupServer(
    rest.patch('https://exercism.test/action', (req, res, ctx) => {
      return res(
        ctx.status(422),
        ctx.json({ error: { message: 'Unable to run action' } })
      )
    })
  )
  server.listen()

  render(<MarkAsNothingToDoButton endpoint="https://exercism.test/action" />)

  userEvent.click(screen.getByRole('button', { name: 'Mark as nothing to do' }))

  expect(await screen.findByText('Unable to run action')).toBeInTheDocument()
  expect(
    await screen.findByRole('button', { name: 'Mark as nothing to do' })
  ).toBeInTheDocument()

  server.close()
})

test('shows generic error message for unexpected errors', async () => {
  silenceConsole()

  render(<MarkAsNothingToDoButton endpoint="wrong" />)

  userEvent.click(screen.getByRole('button', { name: 'Mark as nothing to do' }))

  expect(
    await screen.findByText('Unable to mark discussion as nothing to do')
  ).toBeInTheDocument()
  expect(
    await screen.findByRole('button', { name: 'Mark as nothing to do' })
  ).toBeInTheDocument()
})
