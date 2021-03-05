import React from 'react'
import userEvent from '@testing-library/user-event'
import { rest } from 'msw'
import { setupServer } from 'msw/node'
import { render, screen, waitFor } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { EmptyIterations } from '../../../../../app/javascript/components/student/iteration-page/EmptyIterations'
import { expectConsoleError } from '../../../support/silence-console'
import { TestQueryCache } from '../../../support/TestQueryCache'
import { awaitPopper } from '../../../support/await-popper'

const oldWindowLocation = window.location

beforeAll(() => {
  delete window.location

  window.location = Object.defineProperties(
    {},
    {
      ...Object.getOwnPropertyDescriptors(oldWindowLocation),
      replace: {
        configurable: true,
        value: jest.fn(),
      },
    }
  )
})
beforeEach(() => {
  window.location.replace.mockReset()
})
afterAll(() => {
  window.location = oldWindowLocation
})

test('disables buttons when loading', async () => {
  const server = setupServer(
    rest.patch('https://exercism.test/start', (req, res, ctx) => {
      return res(
        ctx.delay(10),
        ctx.status(200),
        ctx.json({ links: { edit: '' } })
      )
    })
  )
  server.listen()

  render(
    <TestQueryCache>
      <EmptyIterations
        links={{ startExercise: 'https://exercism.test/start' }}
      />
    </TestQueryCache>
  )
  await awaitPopper()
  const startBtn = await screen.findByRole('button', {
    name: 'Start in Editor',
  })
  userEvent.click(startBtn)

  await waitFor(() => {
    expect(startBtn).toBeDisabled()
  })

  server.close()
})

test('shows loading message when loading', async () => {
  const server = setupServer(
    rest.patch('https://exercism.test/start', (req, res, ctx) => {
      return res(
        ctx.delay(10),
        ctx.status(200),
        ctx.json({ links: { edit: '' } })
      )
    })
  )
  server.listen()

  render(
    <TestQueryCache>
      <EmptyIterations
        links={{ startExercise: 'https://exercism.test/start' }}
      />
    </TestQueryCache>
  )
  userEvent.click(
    await screen.findByRole('button', { name: 'Start in Editor' })
  )

  expect(await screen.findByText('Loading')).toBeInTheDocument()

  server.close()
})

test('shows generic errors', async () => {
  expectConsoleError(async () => {
    render(
      <TestQueryCache>
        <EmptyIterations links={{ startExercise: '' }} />
      </TestQueryCache>
    )
    userEvent.click(
      await screen.findByRole('button', { name: 'Start in Editor' })
    )

    expect(
      await screen.findByText('Unable to start exercise')
    ).toBeInTheDocument()
  })
})

test('shows API errors', async () => {
  expectConsoleError(async () => {
    const server = setupServer(
      rest.patch('https://exercism.test/start', (req, res, ctx) => {
        return res(
          ctx.delay(10),
          ctx.status(422),
          ctx.json({ error: { message: 'Unable to start exercise' } })
        )
      })
    )
    server.listen()

    render(
      <TestQueryCache>
        <EmptyIterations
          links={{ startExercise: 'https://exercism.test/start' }}
        />
      </TestQueryCache>
    )
    userEvent.click(
      await screen.findByRole('button', { name: 'Start in Editor' })
    )

    expect(
      await screen.findByText('Unable to start exercise')
    ).toBeInTheDocument()

    server.close()
  })
})
