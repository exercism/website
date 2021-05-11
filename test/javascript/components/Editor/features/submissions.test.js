jest.mock('../../../../../app/javascript/components/editor/FileEditorAce')

import React from 'react'
import {
  render,
  fireEvent,
  waitFor,
  act,
  await,
  screen,
} from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import '@testing-library/jest-dom/extend-expect'
import { rest } from 'msw'
import { setupServer } from 'msw/node'
import { Editor } from '../../../../../app/javascript/components/Editor'

test('shows message when test times out', async () => {
  const server = setupServer(
    rest.post('https://exercism.test/submissions', (req, res, ctx) => {
      return res(
        ctx.delay(10),
        ctx.json({
          submission: {
            id: 2,
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
          },
        })
      )
    })
  )
  server.listen()

  render(
    <Editor
      endpoint="https://exercism.test/submissions"
      files={[{ filename: 'lasagna.rb', content: 'class Lasagna' }]}
      timeout={0}
      assignment={{ overview: '', generalHints: [], tasks: [] }}
    />
  )
  userEvent.click(await screen.findByText('Run Tests'))

  expect(await screen.findByText(/Running tests/)).toBeInTheDocument()
  expect(await screen.findByText('Your tests timed out')).toBeInTheDocument()

  server.close()
})

test('cancels a pending submission', async () => {
  const server = setupServer(
    rest.post('https://exercism.test/submissions', (req, res, ctx) => {
      return res(ctx.delay(10), ctx.json({}))
    })
  )
  server.listen()

  render(
    <Editor
      endpoint="https://exercism.test/submissions"
      files={[{ filename: 'lasagna.rb', content: 'class Lasagna' }]}
      assignment={{ overview: '', generalHints: [], tasks: [] }}
    />
  )
  userEvent.click(await screen.findByText('Run Tests'))
  userEvent.click(await screen.findByText('Cancel'))

  await waitFor(() =>
    expect(screen.queryByText('Running tests...')).not.toBeInTheDocument()
  )

  server.close()
})

test('disables submit button unless tests passed', async () => {
  const server = setupServer(
    rest.get('https://exercism.test/test_run', (req, res, ctx) => {
      return res(
        ctx.delay(10),
        ctx.json({
          test_run: {
            id: null,
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
  server.listen()

  render(
    <Editor
      endpoint="https://exercism.test/submissions"
      files={[{ filename: 'lasagna.rb', content: 'class Lasagna' }]}
      initialSubmission={{
        uuid: '123',
        testsStatus: 'queued',
        links: {
          cancel: 'https://exercism.test/cancel',
          testRun: 'https://exercism.test/test_run',
        },
      }}
      assignment={{
        overview: '',
        generalHints: [],
        tasks: [],
      }}
    />
  )

  await waitFor(() => {
    expect(
      screen.getAllByRole('button', { name: 'Submit F3' })[0]
    ).toBeDisabled()
  })
  server.close()
})

test('disables submit button when files changed', async () => {
  const server = setupServer(
    rest.get('https://exercism.test/test_run', (req, res, ctx) => {
      return res(
        ctx.json({
          test_run: {
            id: null,
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
  server.listen()

  render(
    <Editor
      endpoint="https://exercism.test/submissions"
      files={[{ filename: 'lasagna.rb', content: 'class Lasagna' }]}
      initialSubmission={{
        uuid: '123',
        testsStatus: 'passed',
        links: {
          cancel: 'https://exercism.test/cancel',
          testRun: 'https://exercism.test/test_run',
        },
      }}
      assignment={{
        overview: '',
        generalHints: [],
        tasks: [],
      }}
    />
  )
  const submitButton = screen.getAllByRole('button', { name: 'Submit F3' })[0]

  await waitFor(() => {
    expect(submitButton).not.toBeDisabled()
  })
  fireEvent.change(screen.getByTestId('editor-value'), {
    target: { value: 'class' },
  })
  await waitFor(() => {
    expect(submitButton).toBeDisabled()
  })

  server.close()
})
