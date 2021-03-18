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
  const links = {
    finish: '',
  }

  render(
    <AddTestimonialStep onSubmit={jest.fn()} onBack={jest.fn()} links={links} />
  )
  userEvent.type(screen.getByLabelText('Testimonial'), 'Test')

  expect(
    await screen.findByRole('button', { name: 'Submit testimonial' })
  ).toBeInTheDocument()
})

test('button says "Skip testimonial" if text box is not populated', async () => {
  const links = {
    finish: '',
  }

  render(
    <AddTestimonialStep onSubmit={jest.fn()} onBack={jest.fn()} links={links} />
  )

  expect(
    await screen.findByRole('button', { name: 'Skip testimonial' })
  ).toBeInTheDocument()
})

test('thumbs up icon shows when user starts typing', async () => {
  const links = {
    finish: '',
  }

  render(
    <AddTestimonialStep onSubmit={jest.fn()} onBack={jest.fn()} links={links} />
  )
  userEvent.type(screen.getByLabelText('Testimonial'), 'Test')

  expect(await screen.findByText('Thumbs up')).toBeInTheDocument()
})

test('disables buttons while loading', async () => {
  const links = {
    finish: 'https://exercism.test/mentor_ratings',
  }
  const server = setupServer(
    rest.post('https://exercism.test/mentor_ratings', (req, res, ctx) => {
      return res(ctx.delay(10), ctx.status(200), ctx.json({}))
    })
  )
  server.listen()

  render(
    <TestQueryCache>
      <AddTestimonialStep
        onSubmit={jest.fn()}
        onBack={jest.fn()}
        links={links}
      />
    </TestQueryCache>
  )
  const submitButton = screen.getByRole('button', { name: 'Skip testimonial' })
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
  const links = {
    finish: 'https://exercism.test/mentor_ratings',
  }
  const server = setupServer(
    rest.post('https://exercism.test/mentor_ratings', (req, res, ctx) => {
      return res(ctx.delay(10), ctx.status(200), ctx.json({}))
    })
  )
  server.listen()

  render(
    <TestQueryCache>
      <AddTestimonialStep
        onSubmit={jest.fn()}
        onBack={jest.fn()}
        links={links}
      />
    </TestQueryCache>
  )
  userEvent.click(screen.getByRole('button', { name: 'Skip testimonial' }))

  expect(await screen.findByText('Loading')).toBeInTheDocument()

  server.close()
})

test('shows error message', async () => {
  silenceConsole()
  const links = {
    finish: 'https://exercism.test/mentor_ratings',
  }
  const server = setupServer(
    rest.post('https://exercism.test/mentor_ratings', (req, res, ctx) => {
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
      <AddTestimonialStep
        onSubmit={jest.fn()}
        onBack={jest.fn()}
        links={links}
      />
    </TestQueryCache>
  )
  userEvent.click(screen.getByRole('button', { name: 'Skip testimonial' }))

  expect(await screen.findByText('Unknown error')).toBeInTheDocument()

  server.close()
})

test('shows generic error message', async () => {
  silenceConsole()
  const links = { finish: 'weirdendpoint' }

  render(
    <TestQueryCache>
      <AddTestimonialStep
        onSubmit={jest.fn()}
        onBack={jest.fn()}
        links={links}
      />
    </TestQueryCache>
  )
  userEvent.click(screen.getByRole('button', { name: 'Skip testimonial' }))

  expect(
    await screen.findByText('Unable to submit mentor rating')
  ).toBeInTheDocument()
})
