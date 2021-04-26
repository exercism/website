import React from 'react'
import { render, screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import '@testing-library/jest-dom/extend-expect'
import { SatisfiedStep } from '../../../../../../app/javascript/components/modals/student/finish-mentor-discussion-modal/SatisfiedStep'
import { rest } from 'msw'
import { setupServer } from 'msw/node'
import { TestQueryCache } from '../../../../support/TestQueryCache'
import { silenceConsole } from '../../../../support/silence-console'

test('disables buttons while loading', async () => {
  const links = {
    finish: 'https://exercism.test/mentor_ratings',
  }
  const server = setupServer(
    rest.patch('https://exercism.test/mentor_ratings', (req, res, ctx) => {
      return res(ctx.delay(10), ctx.status(200), ctx.json({}))
    })
  )
  server.listen()

  render(
    <TestQueryCache>
      <SatisfiedStep
        onRequeued={jest.fn()}
        onNotRequeued={jest.fn()}
        onBack={jest.fn()}
        links={links}
      />
    </TestQueryCache>
  )
  const yesButton = screen.getByRole('button', { name: 'Yes please' })
  const noButton = screen.getByRole('button', { name: 'No thanks' })
  const backButton = screen.getByRole('button', { name: 'Back' })
  userEvent.click(yesButton)

  await waitFor(() => {
    expect(yesButton).toBeDisabled()
  })
  await waitFor(() => {
    expect(noButton).toBeDisabled()
  })
  await waitFor(() => {
    expect(backButton).toBeDisabled()
  })

  server.close()
})

test('shows loading message', async () => {
  const links = {
    finish: 'https://exercism.test/mentor_ratings',
  }
  const server = setupServer(
    rest.patch('https://exercism.test/mentor_ratings', (req, res, ctx) => {
      return res(ctx.delay(10), ctx.status(200), ctx.json({}))
    })
  )
  server.listen()

  render(
    <TestQueryCache>
      <SatisfiedStep
        onRequeued={jest.fn()}
        onNotRequeued={jest.fn()}
        onBack={jest.fn()}
        links={links}
      />
    </TestQueryCache>
  )
  userEvent.click(screen.getByRole('button', { name: 'Yes please' }))

  expect(await screen.findByText('Loading')).toBeInTheDocument()

  server.close()
})

test('shows error message', async () => {
  silenceConsole()
  const links = {
    finish: 'https://exercism.test/mentor_ratings',
  }
  const server = setupServer(
    rest.patch('https://exercism.test/mentor_ratings', (req, res, ctx) => {
      return res(
        ctx.delay(10),
        ctx.status(422),
        ctx.json({
          error: {
            message: 'Unknown error',
          },
        })
      )
    })
  )
  server.listen()

  render(
    <TestQueryCache>
      <SatisfiedStep
        onRequeued={jest.fn()}
        onNotRequeued={jest.fn()}
        onBack={jest.fn()}
        links={links}
      />
    </TestQueryCache>
  )
  userEvent.click(screen.getByRole('button', { name: 'Yes please' }))

  expect(await screen.findByText('Unknown error')).toBeInTheDocument()

  server.close()
})

test('shows generic error message', async () => {
  silenceConsole()
  const links = { finish: 'weirdendpoint' }

  render(
    <TestQueryCache>
      <SatisfiedStep
        onRequeued={jest.fn()}
        onNotRequeued={jest.fn()}
        onBack={jest.fn()}
        links={links}
      />
    </TestQueryCache>
  )
  userEvent.click(screen.getByRole('button', { name: 'Yes please' }))

  expect(
    await screen.findByText('Unable to submit mentor rating')
  ).toBeInTheDocument()
})
