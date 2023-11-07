import React from 'react'
import { screen, waitFor } from '@testing-library/react'
import { render } from '../../../../test-utils'
import { rest } from 'msw'
import { setupServer } from 'msw/node'
import '@testing-library/jest-dom/extend-expect'
import { MentoringRequestForm } from '../../../../../../app/javascript/components/student/mentoring-session/mentoring-request/MentoringRequestForm'
import userEvent from '@testing-library/user-event'
import { expectConsoleError } from '../../../../support/silence-console'

const server = setupServer(
  rest.post('https://exercism.test/mentor_requests', (req, res, ctx) => {
    return res(
      ctx.delay(10),
      ctx.status(200),
      ctx.json({
        mentorRequest: {
          id: '1',
        },
      })
    )
  })
)

beforeAll(() => server.listen())
beforeEach(() => server.resetHandlers())
afterAll(() => server.close())

test('disables submit button', async () => {
  const handleSuccess = jest.fn()
  render(
    <MentoringRequestForm
      links={{
        createMentorRequest: 'https://exercism.test/mentor_requests',
      }}
      exercise={{}}
      track={{}}
      onSuccess={handleSuccess}
    />
  )
  const button = screen.getByRole('button', {
    name: 'Submit mentoring request',
  })
  userEvent.click(button)

  await waitFor(() => {
    expect(button).toBeDisabled()
  })
  await waitFor(() => expect(handleSuccess).toHaveBeenCalled())
})

test('shows loading message', async () => {
  const handleSuccess = jest.fn()

  render(
    <MentoringRequestForm
      links={{
        createMentorRequest: 'https://exercism.test/mentor_requests',
      }}
      exercise={{}}
      track={{}}
      onSuccess={handleSuccess}
    />
  )
  userEvent.click(
    screen.getByRole('button', { name: 'Submit mentoring request' })
  )

  expect(await screen.findByText('Loading')).toBeInTheDocument()
  await waitFor(() => expect(handleSuccess).toHaveBeenCalled())
})

test('shows API error message', async () => {
  await expectConsoleError(async () => {
    server.use(
      rest.post('https://exercism.test/mentor_requests', (req, res, ctx) => {
        return res(
          ctx.delay(10),
          ctx.status(422),
          ctx.json({
            error: {
              message: 'No mentors available',
            },
          })
        )
      })
    )

    render(
      <MentoringRequestForm
        links={{
          createMentorRequest: 'https://exercism.test/mentor_requests',
        }}
        exercise={{}}
        track={{}}
        onSuccess={() => null}
      />
    )
    userEvent.click(
      screen.getByRole('button', { name: 'Submit mentoring request' })
    )

    expect(await screen.findByText('No mentors available')).toBeInTheDocument()
  })
})

test('shows generic error message', async () => {
  await expectConsoleError(async () => {
    render(
      <MentoringRequestForm
        links={{
          createMentorRequest: 'weirdendpoint',
        }}
        exercise={{}}
        track={{}}
        onSuccess={() => null}
      />
    )
    userEvent.click(
      screen.getByRole('button', { name: 'Submit mentoring request' })
    )

    expect(
      await screen.findByText('Unable to create mentor request')
    ).toBeInTheDocument()
  })
})
