jest.mock(
  '../../../../../app/javascript/components/editor/FileEditorCodeMirror'
)

import React from 'react'
import { waitFor, screen, act } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import '@testing-library/jest-dom/extend-expect'
import { rest } from 'msw'
import { setupServer } from 'msw/node'
import { Editor } from '../../../../../app/javascript/components/Editor'
import { build } from '@jackfranklin/test-data-bot'
import { render } from '../../../test-utils'

const server = setupServer(
  rest.post('https://exercism.test/submissions', (req, res, ctx) => {
    return res(
      ctx.delay(10),
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
  rest.get('https://exercism.test/test_run', (req, res, ctx) => {
    return res(
      ctx.delay(10),
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
  jest.useFakeTimers()
  server.listen()
})
beforeEach(() => server.resetHandlers())
afterEach(() => localStorage.clear())
afterAll(() => {
  jest.useRealTimers()
  server.close()
})

const buildEditor = build({
  fields: {
    endpoint: 'https://exercism.test/submissions',
    files: [{ filename: 'lasagna.rb', content: 'class Lasagna' }],
    assignment: { overview: '', generalHints: [], tasks: [] },
    timeout: undefined,
    initialSubmission: null,
  },
})

test('shows message when test times out', async () => {
  const timeout = 50000
  const props = buildEditor({ overrides: { timeout: timeout } })

  render(<Editor {...props} />)

  const button = screen.getByRole('button', { name: /Run Tests/ })
  userEvent.type(screen.getByRole('textbox'), 'code')
  await waitFor(() => {
    expect(button).not.toBeDisabled()
  })
  userEvent.click(button)
  expect(
    await screen.findByRole('button', { name: /cancel/i })
  ).toBeInTheDocument()
  act(() => jest.advanceTimersByTime(timeout + 100))
  expect(await screen.findByText('Your tests timed out')).toBeInTheDocument()
})

test('cancels a pending submission', async () => {
  const props = buildEditor()

  render(<Editor {...props} />)

  const button = screen.getByRole('button', { name: /Run Tests/ })
  userEvent.type(screen.getByRole('textbox'), 'code')
  await waitFor(() => {
    expect(button).not.toBeDisabled()
  })
  userEvent.click(button)
  userEvent.click(await screen.findByRole('button', { name: /cancel/i }))
  await waitFor(() =>
    expect(screen.queryByText('Running tests...')).not.toBeInTheDocument()
  )
})

test('disables submit button unless tests passed', async () => {
  const props = buildEditor({
    overrides: {
      initialSubmission: {
        uuid: '123',
        testsStatus: 'queued',
        links: {
          cancel: 'https://exercism.test/cancel',
          testRun: 'https://exercism.test/test_run',
        },
      },
    },
  })

  await act(async () => render(<Editor {...props} />))

  const submitButton = screen.getAllByRole('button', { name: /Submit/ })[0]
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
  const props = buildEditor({
    overrides: {
      initialSubmission: {
        uuid: '123',
        testsStatus: 'passed',
        links: {
          cancel: 'https://exercism.test/cancel',
          testRun: 'https://exercism.test/test_run',
        },
      },
    },
  })

  await act(async () => render(<Editor {...props} />))

  const submitButton = screen.getAllByRole('button', { name: 'Submit F3' })[0]
  await waitFor(() => expect(submitButton).not.toBeDisabled())
  userEvent.type(screen.getByRole('textbox'), 'code')
  await waitFor(() => {
    expect(submitButton).toBeDisabled()
  })
})
