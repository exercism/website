import React from 'react'
import { screen, waitFor } from '@testing-library/react'
import { render } from '../../../test-utils'
import '@testing-library/jest-dom/extend-expect'
import { DeleteIterationModal } from '../../../../../app/javascript/components/student/iterations-list/DeleteIterationModal'
import { createIteration } from '../../../factories/IterationFactory'
import userEvent from '@testing-library/user-event'
import { rest } from 'msw'
import { setupServer } from 'msw/node'
import { expectConsoleError } from '../../../support/silence-console'
import { deferred } from '../../../support/deferred'

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
  const iteration = createIteration({
    links: {
      self: 'https://exercism.test/self',
      solution: 'https://exercism.test/solution',
      files: 'https://exercism.test/files',
      testRun: 'https://exercism.test/test_run',
      delete: 'https://exercism.test/delete',
    },
  })

  render(
    <DeleteIterationModal
      open
      iteration={iteration}
      onClose={jest.fn()}
      onSuccess={jest.fn()}
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
  const iteration = createIteration({
    links: {
      self: 'https://exercism.test/self',
      solution: 'https://exercism.test/solution',
      files: 'https://exercism.test/files',
      testRun: 'https://exercism.test/test_run',
      delete: 'https://exercism.test/delete',
    },
  })
  const handleClose = jest.fn()

  render(
    <DeleteIterationModal
      open
      iteration={iteration}
      onClose={handleClose}
      onSuccess={jest.fn()}
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
    const iteration = createIteration({
      links: {
        self: 'https://exercism.test/self',
        solution: 'https://exercism.test/solution',
        files: 'https://exercism.test/files',
        testRun: 'https://exercism.test/test_run',
        delete: 'https://exercism.test/delete',
      },
    })

    render(
      <DeleteIterationModal
        open
        iteration={iteration}
        onClose={jest.fn()}
        onSuccess={jest.fn()}
      />
    )

    const deleteButton = screen.getByRole('button', { name: /delete/i })
    userEvent.click(deleteButton)

    expect(await screen.findByText('Something went wrong')).toBeInTheDocument()
  })
})

test('shows unexpected errors', async () => {
  await expectConsoleError(async () => {
    const iteration = createIteration({
      links: {
        self: 'https://exercism.test/self',
        solution: 'https://exercism.test/solution',
        files: 'https://exercism.test/files',
        testRun: 'https://exercism.test/test_run',
        delete: 'https://exercism.test/delete',
      },
    })

    render(
      <DeleteIterationModal
        open
        iteration={iteration}
        onClose={jest.fn()}
        onSuccess={jest.fn()}
      />
    )

    const deleteButton = screen.getByRole('button', { name: /delete/i })
    userEvent.click(deleteButton)

    expect(
      await screen.findByText('Unable to delete iteration')
    ).toBeInTheDocument()
  })
})
