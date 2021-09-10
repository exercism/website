import React from 'react'
import userEvent from '@testing-library/user-event'
import { rest } from 'msw'
import { setupServer } from 'msw/node'
import { render } from '../../../test-utils'
import { screen, waitFor } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { EmptyIterations } from '../../../../../app/javascript/components/student/iterations-list/EmptyIterations'
import { expectConsoleError } from '../../../support/silence-console'
import { redirectTo } from '../../../../../app/javascript/utils/redirect-to'

jest.mock('../../../../../app/javascript/utils/redirect-to')

const server = setupServer(
  rest.patch('https://exercism.test/start', (req, res, ctx) => {
    return res(
      ctx.delay(10),
      ctx.status(200),
      ctx.json({ links: { exercise: '' } })
    )
  })
)

beforeAll(() => server.listen())
beforeEach(() => server.resetHandlers())
afterAll(() => server.close())

test('disables buttons when loading', async () => {
  render(
    <EmptyIterations
      exercise={{ hasTestRunner: true }}
      links={{ startExercise: 'https://exercism.test/start' }}
    />
  )

  const startBtn = await screen.findByRole('button', {
    name: 'Start in Editor',
  })

  userEvent.click(startBtn)

  await waitFor(() => {
    expect(startBtn).toBeDisabled()
  })
})

test('shows loading message when loading', async () => {
  render(
    <EmptyIterations
      exercise={{ hasTestRunner: true }}
      links={{ startExercise: 'https://exercism.test/start' }}
    />
  )

  userEvent.click(
    await screen.findByRole('button', { name: 'Start in Editor' })
  )

  expect(await screen.findByText('Loading')).toBeInTheDocument()

  await waitFor(() => expect(redirectTo).toHaveBeenCalled())
})

test('shows generic errors', async () => {
  await expectConsoleError(async () => {
    render(
      <EmptyIterations
        exercise={{ hasTestRunner: true }}
        links={{ startExercise: 'weirdendpoint' }}
      />
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
  await expectConsoleError(async () => {
    server.use(
      rest.patch('https://exercism.test/start', (req, res, ctx) => {
        return res(
          ctx.delay(10),
          ctx.status(422),
          ctx.json({ error: { message: 'Unable to start' } })
        )
      })
    )

    render(
      <EmptyIterations
        exercise={{ hasTestRunner: true }}
        links={{ startExercise: 'https://exercism.test/start' }}
      />
    )
    userEvent.click(
      await screen.findByRole('button', { name: 'Start in Editor' })
    )

    expect(await screen.findByText('Unable to start')).toBeInTheDocument()
  })
})
