import React from 'react'
import { render, screen, waitFor, act } from '@testing-library/react'
import { rest } from 'msw'
import { setupServer } from 'msw/node'
import '@testing-library/jest-dom/extend-expect'
import { StartMentoringPanel } from '../../../../../app/javascript/components/mentoring/request/StartMentoringPanel'
import { silenceConsole } from '../../../support/silence-console'
import userEvent from '@testing-library/user-event'
import flushPromises from 'flush-promises'
import { awaitPopper } from '../../../support/await-popper'

test('shows loading message while locking mentoring request', async () => {
  const request = {
    links: {
      lock: 'https://exercism.test/lock',
    },
  }
  const server = setupServer(
    rest.patch('https://exercism.test/lock', (req, res, ctx) => {
      return res(ctx.delay(10), ctx.status(200), ctx.json({ request: {} }))
    })
  )
  server.listen()

  render(<StartMentoringPanel request={request} setRequest={() => null} />)
  userEvent.click(
    await screen.findByRole('button', { name: 'Start mentoring' })
  )

  expect(await screen.findByText('Loading')).toBeInTheDocument()

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
  await flushPromises()
  await awaitPopper()

  act(() => {
    render(<StartMentoringPanel request={request} setRequest={() => null} />)
  })
  await awaitPopper()

  const button = await screen.findByRole('button', { name: 'Start mentoring' })
  userEvent.click(button)

  await waitFor(() => {
    expect(button).toBeDisabled()
  })

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
        ctx.delay(10),
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
