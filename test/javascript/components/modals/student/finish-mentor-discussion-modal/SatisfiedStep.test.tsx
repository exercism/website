import React from 'react'
import { screen, waitFor } from '@testing-library/react'
import { render } from '../../../../test-utils'
import userEvent from '@testing-library/user-event'
import '@testing-library/jest-dom/extend-expect'
import { SatisfiedStep } from '../../../../../../app/javascript/components/modals/student/finish-mentor-discussion-modal/SatisfiedStep'
import { rest } from 'msw'
import { setupServer } from 'msw/node'
import {
  expectConsoleError,
  silenceConsole,
} from '../../../../support/silence-console'
import { createMentorDiscussion } from '../../../../factories/MentorDiscussionFactory'

const server = setupServer(
  rest.patch('https://exercism.test/mentor_ratings', (req, res, ctx) => {
    return res(ctx.delay(100), ctx.status(200), ctx.json({}))
  })
)

beforeAll(() => server.listen())
beforeEach(() => server.resetHandlers())
afterAll(() => server.close())

test('disables buttons while loading', async () => {
  const handleSuccess = jest.fn()
  const discussion = createMentorDiscussion({
    links: {
      self: '',
      markAsNothingToDo: '',
      posts: '',
      finish: 'https://exercism.test/mentor_ratings',
    },
  })

  render(
    <SatisfiedStep
      onRequeued={handleSuccess}
      onNotRequeued={handleSuccess}
      onBack={jest.fn()}
      discussion={discussion}
    />
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

  await waitFor(() => {
    expect(handleSuccess).toHaveBeenCalled()
  })
})

test('shows loading message', async () => {
  const handleSuccess = jest.fn()
  const discussion = createMentorDiscussion({
    links: {
      self: '',
      markAsNothingToDo: '',
      posts: '',
      finish: 'https://exercism.test/mentor_ratings',
    },
  })

  render(
    <SatisfiedStep
      onRequeued={handleSuccess}
      onNotRequeued={handleSuccess}
      onBack={jest.fn()}
      discussion={discussion}
    />
  )

  const yesButton = screen.getByRole('button', { name: 'Yes please' })
  userEvent.click(yesButton)

  expect(await screen.findByText('Loading')).toBeInTheDocument()
  await waitFor(() => {
    expect(handleSuccess).toHaveBeenCalled()
  })
})

test('shows error message', async () => {
  await expectConsoleError(async () => {
    const discussion = createMentorDiscussion({
      links: {
        self: '',
        markAsNothingToDo: '',
        posts: '',
        finish: 'https://exercism.test/mentor_ratings',
      },
    })
    server.use(
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

    render(
      <SatisfiedStep
        onRequeued={jest.fn()}
        onNotRequeued={jest.fn()}
        onBack={jest.fn()}
        discussion={discussion}
      />
    )
    userEvent.click(screen.getByRole('button', { name: 'Yes please' }))

    expect(await screen.findByText('Unknown error')).toBeInTheDocument()
  })
})

test('shows generic error message', async () => {
  await expectConsoleError(async () => {
    const discussion = createMentorDiscussion({
      links: {
        self: '',
        markAsNothingToDo: '',
        posts: '',
        finish: 'weirdendpoint',
      },
    })

    render(
      <SatisfiedStep
        onRequeued={jest.fn()}
        onNotRequeued={jest.fn()}
        onBack={jest.fn()}
        discussion={discussion}
      />
    )
    userEvent.click(screen.getByRole('button', { name: 'Yes please' }))

    expect(
      await screen.findByText('Unable to submit mentor rating')
    ).toBeInTheDocument()
  })
})
