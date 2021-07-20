import React from 'react'
import { render, screen, waitFor } from '@testing-library/react'
import { rest } from 'msw'
import { setupServer } from 'msw/node'
import '@testing-library/jest-dom/extend-expect'
import { StartMentoringPanel } from '../../../../../app/javascript/components/mentoring/request/StartMentoringPanel'
import {
  expectConsoleError,
  silenceConsole,
} from '../../../support/silence-console'
import userEvent from '@testing-library/user-event'

const server = setupServer(
  rest.patch('https://exercism.test/lock', (req, res, ctx) => {
    return res(ctx.delay(10), ctx.status(200), ctx.json({ request: {} }))
  })
)

beforeAll(() => server.listen())
beforeEach(() => server.resetHandlers())
afterAll(() => server.close())

test('shows loading message while locking mentoring request', async () => {
  const handleSet = jest.fn()
  const request = {
    student: { handle: 'someone' },
    track: { title: 'Ruby' },
    links: {
      lock: 'https://exercism.test/lock',
    },
  }

  render(<StartMentoringPanel request={request} setRequest={handleSet} />)
  userEvent.click(
    await screen.findByRole('button', { name: 'Start mentoring' })
  )

  expect(await screen.findByText('Loading')).toBeInTheDocument()

  await waitFor(() => expect(handleSet).toHaveBeenCalled())
})

test('disables button while locking mentoring request', async () => {
  const handleSet = jest.fn()
  const request = {
    student: { handle: 'someone' },
    track: { title: 'Ruby' },
    links: {
      lock: 'https://exercism.test/lock',
    },
  }

  render(<StartMentoringPanel request={request} setRequest={handleSet} />)

  const button = await screen.findByRole('button', { name: 'Start mentoring' })
  userEvent.click(button)

  await waitFor(() => {
    expect(button).toBeDisabled()
  })

  await waitFor(() => expect(handleSet).toHaveBeenCalled())
})

test('shows API errors', async () => {
  await expectConsoleError(async () => {
    const request = {
      student: { handle: 'someone' },
      track: { title: 'Ruby' },
      links: {
        lock: 'https://exercism.test/lock',
      },
    }
    server.use(
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

    render(<StartMentoringPanel request={request} />)
    userEvent.click(screen.getByRole('button', { name: 'Start mentoring' }))

    expect(
      await screen.findByText('Unable to lock solution')
    ).toBeInTheDocument()
  })
})

test('shows generic errors', async () => {
  await expectConsoleError(async () => {
    const request = {
      student: { handle: 'someone' },
      track: { title: 'Ruby' },
      links: {
        lock: 'weirdendpoint',
      },
    }

    render(<StartMentoringPanel request={request} />)
    userEvent.click(screen.getByRole('button', { name: 'Start mentoring' }))

    expect(
      await screen.findByText('Unable to lock solution')
    ).toBeInTheDocument()
  })
})
