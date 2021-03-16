import React from 'react'
import { render, screen, waitFor } from '@testing-library/react'
import { rest } from 'msw'
import { setupServer } from 'msw/node'
import '@testing-library/jest-dom/extend-expect'
import { MentoringRequestForm } from '../../../../../../app/javascript/components/student/mentoring-session/mentoring-request/MentoringRequestForm'
import userEvent from '@testing-library/user-event'
import { silenceConsole } from '../../../../support/silence-console'

test('disables submit button', async () => {
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
  server.listen()

  render(
    <MentoringRequestForm
      links={{
        createMentorRequest: 'https://exercism.test/mentor_requests',
      }}
      exercise={{}}
      track={{}}
      onSuccess={() => {}}
    />
  )
  const button = screen.getByRole('button', {
    name: 'Submit mentoring request',
  })
  userEvent.click(button)

  await waitFor(() => {
    expect(button).toBeDisabled()
  })

  server.close()
})

test('shows loading message', async () => {
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
  server.listen()

  render(
    <MentoringRequestForm
      links={{
        createMentorRequest: 'https://exercism.test/mentor_requests',
      }}
      exercise={{}}
      track={{}}
      onSuccess={() => {}}
    />
  )
  userEvent.click(
    screen.getByRole('button', { name: 'Submit mentoring request' })
  )

  expect(await screen.findByText('Loading')).toBeInTheDocument()

  server.close()
})

test('shows API error message', async () => {
  silenceConsole()
  const server = setupServer(
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
  server.listen()

  render(
    <MentoringRequestForm
      links={{
        createMentorRequest: 'https://exercism.test/mentor_requests',
      }}
      exercise={{}}
      track={{}}
      onSuccess={() => {}}
    />
  )
  userEvent.click(
    screen.getByRole('button', { name: 'Submit mentoring request' })
  )

  expect(await screen.findByText('No mentors available')).toBeInTheDocument()

  server.close()
})

test('shows generic error message', async () => {
  silenceConsole()
  render(
    <MentoringRequestForm
      links={{
        createMentorRequest: 'weirdendpoint',
      }}
      exercise={{}}
      track={{}}
      onSuccess={() => {}}
    />
  )
  userEvent.click(
    screen.getByRole('button', { name: 'Submit mentoring request' })
  )

  expect(
    await screen.findByText('Unable to create mentor request')
  ).toBeInTheDocument()
})
