import React from 'react'
import { screen, waitFor } from '@testing-library/react'
import { render } from '../../../../test-utils'
import '@testing-library/jest-dom/extend-expect'
import { DeleteTestimonialModal } from '../../../../../../app/javascript/components/mentoring/testimonials-list/revealed-testimonial/DeleteTestimonialModal'
import { createTestimonial } from '../../../../factories/TestimonialFactory'
import userEvent from '@testing-library/user-event'
import { rest } from 'msw'
import { setupServer } from 'msw/node'
import { expectConsoleError } from '../../../../support/silence-console'
import { deferred } from '../../../../support/deferred'

const server = setupServer()

beforeAll(() => {
  server.listen()
})
afterEach(() => {
  server.resetHandlers()
})
afterAll(() => {
  server.close()
})

test('disables buttons when submitting', async () => {
  const { promise } = deferred()
  server.use(
    rest.delete('https://exercism.test/delete', (req, res, ctx) => {
      return promise.then(() => {
        res(ctx.json({}))
      })
    })
  )
  const testimonial = createTestimonial({
    overrides: {
      links: {
        reveal: 'https://exercism.test/reveal',
        delete: 'https://exercism.test/delete',
      },
    },
  })

  render(
    <DeleteTestimonialModal
      open
      testimonial={testimonial}
      cacheKey={['CACHE_KEY']}
      onClose={jest.fn()}
    />
  )

  const deleteButton = screen.getByRole('button', { name: /delete/i })
  const cancelButton = screen.getByRole('button', { name: /cancel/i })
  userEvent.click(deleteButton)

  await waitFor(() => {
    expect(deleteButton).toBeDisabled()
    expect(cancelButton).toBeDisabled()
  })
})
test('unable to close modal when submitting', async () => {
  const { promise } = deferred()
  server.use(
    rest.delete('https://exercism.test/delete', (req, res, ctx) => {
      return promise.then(() => {
        res(ctx.json({}))
      })
    })
  )
  const testimonial = createTestimonial({
    overrides: {
      links: {
        reveal: 'https://exercism.test/reveal',
        delete: 'https://exercism.test/delete',
      },
    },
  })
  const handleClose = jest.fn()

  render(
    <DeleteTestimonialModal
      open
      testimonial={testimonial}
      cacheKey={['CACHE_KEY']}
      onClose={handleClose}
    />
  )

  const deleteButton = screen.getByRole('button', { name: /delete/i })
  userEvent.click(deleteButton)
  userEvent.type(screen.getByRole('dialog'), '{esc}')

  expect(handleClose).not.toHaveBeenCalled()
})

test('shows api errors', async () => {
  await expectConsoleError(async () => {
    server.use(
      rest.delete('https://exercism.test/delete', (req, res, ctx) => {
        return res(
          ctx.status(422),
          ctx.json({
            error: {
              message: 'Something went wrong',
            },
          })
        )
      })
    )
    const testimonial = createTestimonial({
      overrides: {
        links: {
          reveal: 'https://exercism.test/reveal',
          delete: 'https://exercism.test/delete',
        },
      },
    })

    render(
      <DeleteTestimonialModal
        open
        testimonial={testimonial}
        cacheKey={['CACHE_KEY']}
        onClose={jest.fn()}
      />
    )

    const deleteButton = screen.getByRole('button', { name: /delete/i })
    userEvent.click(deleteButton)

    expect(await screen.findByText('Something went wrong')).toBeInTheDocument()
  })
})

test('shows unexpected errors', async () => {
  await expectConsoleError(async () => {
    const testimonial = createTestimonial({
      overrides: {
        links: {
          reveal: 'https://exercism.test/reveal',
          delete: 'wrongendpoint',
        },
      },
    })

    render(
      <DeleteTestimonialModal
        open
        testimonial={testimonial}
        cacheKey={['CACHE_KEY']}
        onClose={jest.fn()}
      />
    )

    const deleteButton = screen.getByRole('button', { name: /delete/i })
    userEvent.click(deleteButton)

    expect(
      await screen.findByText('Unable to delete testimonial')
    ).toBeInTheDocument()
  })
})
