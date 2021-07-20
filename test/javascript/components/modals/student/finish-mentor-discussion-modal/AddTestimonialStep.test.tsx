import React from 'react'
import { render } from '../../../../test-utils'
import {
  screen,
  waitFor,
  waitForElementToBeRemoved,
} from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import '@testing-library/jest-dom/extend-expect'
import { AddTestimonialStep } from '../../../../../../app/javascript/components/modals/student/finish-mentor-discussion-modal/AddTestimonialStep'
import { rest } from 'msw'
import { setupServer } from 'msw/node'
import {
  expectConsoleError,
  silenceConsole,
} from '../../../../support/silence-console'
import { createMentorDiscussion } from '../../../../factories/MentorDiscussionFactory'

const server = setupServer(
  rest.patch('https://exercism.test/mentor_ratings', (req, res, ctx) => {
    return res(ctx.status(200), ctx.json({}))
  })
)

beforeAll(() => server.listen())
beforeEach(() => server.resetHandlers())
afterAll(() => server.close())

test('button says "Submit testimonial" if text box is populated', async () => {
  render(
    <AddTestimonialStep
      onSubmit={jest.fn()}
      onBack={jest.fn()}
      discussion={createMentorDiscussion()}
    />
  )
  userEvent.type(screen.getByLabelText(/Leave mentor a testimonial/), 'Test')

  expect(
    await screen.findByRole('button', { name: 'Finish' })
  ).toBeInTheDocument()
})

test('button says "Skip testimonial" if text box is not populated', async () => {
  render(
    <AddTestimonialStep
      onSubmit={jest.fn()}
      onBack={jest.fn()}
      discussion={createMentorDiscussion()}
    />
  )

  expect(
    await screen.findByRole('button', { name: 'Skip' })
  ).toBeInTheDocument()
})

test('disables buttons while loading', async () => {
  const discussion = createMentorDiscussion({
    links: {
      self: '',
      posts: '',
      markAsNothingToDo: '',
      finish: 'https://exercism.test/mentor_ratings',
    },
  })

  render(
    <AddTestimonialStep
      onSubmit={jest.fn()}
      onBack={jest.fn()}
      discussion={discussion}
    />
  )
  const submitButton = screen.getByRole('button', { name: 'Skip' })
  const skipButton = screen.getByRole('button', { name: 'Back' })
  userEvent.click(submitButton)

  await waitFor(() => {
    expect(submitButton).toBeDisabled()
  })
  await waitFor(() => {
    expect(skipButton).toBeDisabled()
  })
})

test('shows loading message', async () => {
  const discussion = createMentorDiscussion({
    links: {
      self: '',
      posts: '',
      markAsNothingToDo: '',
      finish: 'https://exercism.test/mentor_ratings',
    },
  })

  render(
    <AddTestimonialStep
      onSubmit={jest.fn()}
      onBack={jest.fn()}
      discussion={discussion}
    />
  )
  userEvent.click(screen.getByRole('button', { name: 'Skip' }))

  expect(await screen.findByText('Loading')).toBeInTheDocument()

  await waitForElementToBeRemoved(() => screen.getByText('Loading'))
})

test('shows error message', async () => {
  await expectConsoleError(async () => {
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
    const discussion = createMentorDiscussion({
      links: {
        self: '',
        posts: '',
        markAsNothingToDo: '',
        finish: 'https://exercism.test/mentor_ratings',
      },
    })

    render(
      <AddTestimonialStep
        onSubmit={jest.fn()}
        onBack={jest.fn()}
        discussion={discussion}
      />
    )
    userEvent.click(screen.getByRole('button', { name: 'Skip' }))

    expect(await screen.findByText('Unknown error')).toBeInTheDocument()
  })
})

test('shows generic error message', async () => {
  await expectConsoleError(async () => {
    const discussion = createMentorDiscussion({
      links: {
        self: '',
        posts: '',
        markAsNothingToDo: '',
        finish: 'weirdendpoint',
      },
    })

    render(
      <AddTestimonialStep
        onSubmit={jest.fn()}
        onBack={jest.fn()}
        discussion={discussion}
      />
    )
    userEvent.click(screen.getByRole('button', { name: 'Skip' }))

    expect(
      await screen.findByText('Unable to submit mentor rating')
    ).toBeInTheDocument()
  })
})
