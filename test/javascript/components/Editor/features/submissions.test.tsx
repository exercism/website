jest.mock(
  '../../../../../app/javascript/components/editor/FileEditorCodeMirror'
)

import React from 'react'
import { waitFor, screen, fireEvent } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import '@testing-library/jest-dom/extend-expect'
import { rest } from 'msw'
import { setupServer } from 'msw/node'
import Editor from '../../../../../app/javascript/components/Editor'
import { render } from '../../../test-utils'
import { buildEditor } from './buildEditor'
import { deferred } from '../../../support/deferred'

const server = setupServer(
  rest.post('https://exercism.test/submissions', (req, res, ctx) => {
    return res(
      ctx.json({
        submission: {
          uuid: '123',
          tests_status: 'queued',
          links: {
            cancel: 'https://exercism.test/cancel',
            testRun: 'https://exercism.test/test_run',
          },
        },
      })
    )
  }),
  rest.patch('https://exercism.test/cancel', (req, res, ctx) => {
    return res(ctx.json({}))
  }),
  rest.get('https://exercism.test/test_run', (req, res, ctx) => {
    return res(
      ctx.json({
        test_run: {
          submission_uuid: '123',
          status: 'queued',
          message: '',
          tests: [],
          links: {
            self: 'https://exercism.test/test_run',
          },
        },
      })
    )
  })
)

beforeAll(() => {
  server.listen()
})
afterEach(() => {
  localStorage.clear()
  server.resetHandlers()
})
afterAll(() => {
  server.close()
})

test('shows message when test times out', async () => {
  const props = buildEditor({ overrides: { timeout: 1000 } })
  const { promise } = deferred()

  server.use(
    rest.get('https://exercism.test/test_run', (req, res, ctx) => {
      return promise.then(() => {
        res(
          ctx.json({
            test_run: {
              submission_uuid: '123',
              status: 'queued',
              message: '',
              tests: [],
              links: {
                self: 'https://exercism.test/test_run',
              },
            },
          })
        )
      })
    })
  )

  render(<Editor {...props} />)

  userEvent.click(screen.getByRole('button', { name: /Run Tests/ }))
  expect(await screen.findByText(/Running tests/i)).toBeInTheDocument()
  expect(await screen.findByText('Your tests timed out')).toBeInTheDocument()
})

test('cancels a pending submission', async () => {
  const props = buildEditor()

  render(<Editor {...props} />)

  userEvent.click(screen.getByRole('button', { name: /Run Tests/ }))
  expect(await screen.findByText('Running tests…')).toBeInTheDocument()
  userEvent.click(await screen.findByRole('button', { name: /cancel/i }))

  expect(await screen.findByText('Test run cancelled')).toBeInTheDocument()
})
test('makes editor readonly while submitting tests', async () => {
  const props = buildEditor()

  render(<Editor {...props} />)

  userEvent.click(screen.getByRole('button', { name: /Run Tests/ }))
  expect(await screen.findByText('Running tests…')).toBeInTheDocument()
  expect(screen.getByText('Readonly: true')).toBeInTheDocument()
})

test('disables submit button unless tests passed', async () => {
  const props = buildEditor({
    overrides: {
      defaultSubmissions: [
        {
          testsStatus: 'queued',
          links: {
            cancel: 'https://exercism.test/cancel',
            testRun: 'https://exercism.test/test_run',
          },
        },
      ],
    },
  })

  render(<Editor {...props} />)

  const submitButton = (
    await screen.findAllByRole('button', { name: /submit/i })
  )[0]
  expect(submitButton).toBeDisabled()
})

test('disables submit button when files changed', async () => {
  server.use(
    rest.get('https://exercism.test/test_run', (req, res, ctx) => {
      return res(
        ctx.json({
          test_run: {
            uuid: null,
            submission_uuid: '123',
            status: 'pass',
            message: '',
            tests: [],
            links: {
              self: 'https://exercism.test/test_run',
            },
          },
        })
      )
    })
  )
  const interval = 1
  const props = buildEditor({
    overrides: {
      defaultSubmissions: [
        {
          uuid: '123',
          testRun: {
            status: 'pass',
            links: {
              self: 'https://exercism.test/test_run',
            },
          },
          links: {
            cancel: 'https://exercism.test/cancel',
            testRun: 'https://exercism.test/test_run',
          },
        },
      ],
      autosave: { saveInterval: interval },
    },
  })

  render(<Editor {...props} />)

  const submitButton = (
    await screen.findAllByRole('button', { name: /submit/i })
  )[0]
  expect(submitButton).not.toBeDisabled()
  fireEvent.change(screen.getByTestId('editor-value'), {
    target: { value: 'code' },
  })
  await waitFor(() => {
    expect(submitButton).toBeDisabled()
  })
})
