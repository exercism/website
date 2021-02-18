import React from 'react'
import { render, screen } from '@testing-library/react'
import { rest } from 'msw'
import { setupServer } from 'msw/node'
import '@testing-library/jest-dom/extend-expect'
import { StartMentoringPanel } from '../../../../../app/javascript/components/mentoring/request/StartMentoringPanel'
import { silenceConsole } from '../../../support/silence-console'
import userEvent from '@testing-library/user-event'

test('shows loading message while locking mentoring request', async () => {
  const request = {
    links: {
      lock: 'https://exercism.test/lock',
    },
  }
  const server = setupServer(
    rest.patch('https://exercism.test/lock', (req, res, ctx) => {
      return res(ctx.status(200), ctx.json({ request: {} }))
    })
  )
  server.listen()

  render(<StartMentoringPanel request={request} />)
  userEvent.click(screen.getByRole('button', { name: 'Start mentoring' }))

  expect(screen.getByText('Loading')).toBeInTheDocument()

  server.close()
})

test('disables button while locking mentoring request', async () => {
  const request = {
    links: {
      lock: 'https://exercism.test/lock',
    },
  }
  const server = setupServer(
    rest.patch('https://exercism.test/lock', (req, res, ctx) => {
      return res(ctx.status(200), ctx.json({ request: {} }))
    })
  )
  server.listen()

  render(<StartMentoringPanel request={request} />)
  userEvent.click(screen.getByRole('button', { name: 'Start mentoring' }))

  expect(screen.getByRole('button', { name: 'Start mentoring' })).toBeDisabled()

  server.close()
})

test('shows API errors', async () => {
  silenceConsole()
  const request = {
    links: {
      lock: 'https://exercism.test/lock',
    },
  }
  const server = setupServer(
    rest.patch('https://exercism.test/lock', (req, res, ctx) => {
      return res(
        ctx.status(422),
        ctx.json({
          error: {
            message: 'Unable to lock solution',
          },
        })
      )
    })
  )
  server.listen()

  render(<StartMentoringPanel request={request} />)
  userEvent.click(screen.getByRole('button', { name: 'Start mentoring' }))

  expect(await screen.findByText('Unable to lock solution')).toBeInTheDocument()

  server.close()
})

test('shows generic errors', async () => {
  silenceConsole()
  const request = {
    links: {
      lock: 'weirdendpoint',
    },
  }

  render(<StartMentoringPanel request={request} />)
  userEvent.click(screen.getByRole('button', { name: 'Start mentoring' }))

  expect(await screen.findByText('Unable to lock solution')).toBeInTheDocument()
})
