import React from 'react'
import { render, screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import '@testing-library/jest-dom/extend-expect'
import { AddTestimonialStep } from '../../../../../../app/javascript/components/modals/student/finish-mentor-discussion-modal/AddTestimonialStep'
import { rest } from 'msw'
import { setupServer } from 'msw/node'
import { TestQueryCache } from '../../../../support/TestQueryCache'
import { silenceConsole } from '../../../../support/silence-console'

test('button says "Submit testimonial" if text box is populated', async () => {
  const discussion = {
    mentor: {
      handle: 'mentor',
    },
    links: {
      finish: '',
    },
  }

  render(
    <AddTestimonialStep
      onSubmit={jest.fn()}
      onBack={jest.fn()}
      discussion={discussion}
    />
  )
  userEvent.type(screen.getByLabelText(/Leave mentor a testimonial/), 'Test')

  expect(
    await screen.findByRole('button', { name: 'Finish' })
  ).toBeInTheDocument()
})

test('button says "Skip testimonial" if text box is not populated', async () => {
  const discussion = {
    mentor: {
      handle: 'mentor',
    },
    links: {
      finish: '',
    },
  }

  render(
    <AddTestimonialStep
      onSubmit={jest.fn()}
      onBack={jest.fn()}
      discussion={discussion}
    />
  )

  expect(
    await screen.findByRole('button', { name: 'Skip' })
  ).toBeInTheDocument()
})

test('disables buttons while loading', async () => {
  const server = setupServer(
    rest.patch('https://exercism.test/mentor_ratings', (req, res, ctx) => {
      return res(ctx.delay(10), ctx.status(200), ctx.json({}))
    })
  )
  const discussion = {
    mentor: {
      handle: 'mentor',
    },
    links: {
      finish: 'https://exercism.test/mentor_ratings',
    },
  }
  server.listen()

  render(
    <TestQueryCache>
      <AddTestimonialStep
        onSubmit={jest.fn()}
        onBack={jest.fn()}
        discussion={discussion}
      />
    </TestQueryCache>
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

  server.close()
})

test('shows loading message', async () => {
  const server = setupServer(
    rest.patch('https://exercism.test/mentor_ratings', (req, res, ctx) => {
      return res(ctx.delay(10), ctx.status(200), ctx.json({}))
    })
  )
  const discussion = {
    mentor: {
      handle: 'mentor',
    },
    links: {
      finish: 'https://exercism.test/mentor_ratings',
    },
  }
  server.listen()

  render(
    <TestQueryCache>
      <AddTestimonialStep
        onSubmit={jest.fn()}
        onBack={jest.fn()}
        discussion={discussion}
      />
    </TestQueryCache>
  )
  userEvent.click(screen.getByRole('button', { name: 'Skip' }))

  expect(await screen.findByText('Loading')).toBeInTheDocument()

  server.close()
})

test('shows error message', async () => {
  silenceConsole()
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
  const discussion = {
    mentor: {
      handle: 'mentor',
    },
    links: {
      finish: 'https://exercism.test/mentor_ratings',
    },
  }
  server.listen()

  render(
    <TestQueryCache>
      <AddTestimonialStep
        onSubmit={jest.fn()}
        onBack={jest.fn()}
        discussion={discussion}
      />
    </TestQueryCache>
  )
  userEvent.click(screen.getByRole('button', { name: 'Skip' }))

  expect(await screen.findByText('Unknown error')).toBeInTheDocument()

  server.close()
})

test('shows generic error message', async () => {
  silenceConsole()
  const discussion = {
    mentor: {
      handle: 'mentor',
    },
    links: { finish: 'weirdendpoint' },
  }

  render(
    <TestQueryCache>
      <AddTestimonialStep
        onSubmit={jest.fn()}
        onBack={jest.fn()}
        discussion={discussion}
      />
    </TestQueryCache>
  )
  userEvent.click(screen.getByRole('button', { name: 'Skip' }))

  expect(
    await screen.findByText('Unable to submit mentor rating')
  ).toBeInTheDocument()
})
