import React from 'react'
import { screen, waitFor } from '@testing-library/react'
import { render } from '../../../../test-utils'
import userEvent from '@testing-library/user-event'
import '@testing-library/jest-dom/extend-expect'
import { ReportStep } from '../../../../../../app/javascript/components/modals/student/finish-mentor-discussion-modal/ReportStep'
import { rest } from 'msw'
import { setupServer } from 'msw/node'
import { expectConsoleError } from '../../../../support/silence-console'
import { createMentorDiscussion } from '../../../../factories/MentorDiscussionFactory'

const server = setupServer(
  rest.patch('https://exercism.test/mentor_ratings', (req, res, ctx) => {
    return res(ctx.delay(10), ctx.status(200), ctx.json({}))
  })
)

beforeAll(() => server.listen())
beforeEach(() => server.resetHandlers())
afterAll(() => server.close())

test('textarea is shown when Report is checked', async () => {
  render(
    <ReportStep
      onSubmit={jest.fn()}
      onBack={jest.fn()}
      discussion={createMentorDiscussion()}
    />
  )
  userEvent.click(screen.getByLabelText('Report this discussion to an admin'))

  expect(await screen.findByLabelText('What went wrong?')).toBeInTheDocument()
})

test('textarea is hidden when Report is not checked', async () => {
  render(
    <ReportStep
      onSubmit={jest.fn()}
      onBack={jest.fn()}
      discussion={createMentorDiscussion()}
    />
  )

  expect(screen.queryByLabelText('What went wrong?')).not.toBeInTheDocument()
})

test('requeue is checked by default', async () => {
  render(
    <ReportStep
      onSubmit={jest.fn()}
      onBack={jest.fn()}
      discussion={createMentorDiscussion()}
    />
  )

  expect(
    screen.getByLabelText('Put your solution back in the queue for mentoring')
  ).toBeChecked()
})

test('disables buttons while loading', async () => {
  const handleSubmit = jest.fn()
  const discussion = createMentorDiscussion({
    links: {
      self: '',
      posts: '',
      markAsNothingToDo: '',
      finish: 'https://exercism.test/mentor_ratings',
    },
  })

  render(
    <ReportStep
      onSubmit={handleSubmit}
      onBack={jest.fn()}
      discussion={discussion}
    />
  )
  const submitButton = screen.getByRole('button', { name: 'Finish' })
  const backButton = screen.getByRole('button', { name: 'Back' })
  userEvent.click(submitButton)

  await waitFor(() => {
    expect(submitButton).toBeDisabled()
  })
  await waitFor(() => {
    expect(backButton).toBeDisabled()
  })
  await waitFor(() => {
    expect(handleSubmit).toHaveBeenCalled()
  })
})

test('shows loading message', async () => {
  const handleSubmit = jest.fn()
  const discussion = createMentorDiscussion({
    links: {
      self: '',
      posts: '',
      markAsNothingToDo: '',
      finish: 'https://exercism.test/mentor_ratings',
    },
  })

  render(
    <ReportStep
      onSubmit={handleSubmit}
      onBack={jest.fn()}
      discussion={discussion}
    />
  )
  const submitButton = screen.getByRole('button', { name: 'Finish' })
  userEvent.click(submitButton)

  expect(await screen.findByText('Loading')).toBeInTheDocument()

  await waitFor(() => {
    expect(handleSubmit).toHaveBeenCalled()
  })
})

test('shows error message', async () => {
  await expectConsoleError(async () => {
    const discussion = createMentorDiscussion({
      links: {
        self: '',
        posts: '',
        markAsNothingToDo: '',
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
      <ReportStep
        onSubmit={jest.fn()}
        onBack={jest.fn()}
        discussion={discussion}
      />
    )
    userEvent.click(screen.getByRole('button', { name: 'Finish' }))

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
        finish: 'wrongendpoint',
      },
    })

    render(
      <ReportStep
        onSubmit={jest.fn()}
        onBack={jest.fn()}
        discussion={discussion}
      />
    )
    userEvent.click(screen.getByRole('button', { name: 'Finish' }))

    expect(
      await screen.findByText('Unable to submit mentor rating')
    ).toBeInTheDocument()
  })
})
