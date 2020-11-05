import React from 'react'
import { render, fireEvent, waitFor } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { rest } from 'msw'
import { setupServer } from 'msw/node'
import { Editor } from '../../../../app/javascript/components/student/Editor'

test('clears current submission when resubmitting', async () => {
  const server = setupServer(
    rest.post('https://exercism.test/submissions', (req, res, ctx) => {
      return res(
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
        ctx.json({
          test_run: {
            id: null,
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

  const { getByText, queryByText } = render(
    <Editor
      endpoint="https://exercism.test/submissions"
      files={[{ filename: 'lasagna.rb', content: 'class Lasagna' }]}
    />
  )
  fireEvent.click(getByText('Run tests'))
  await waitFor(() => expect(queryByText('Status: queued')).toBeInTheDocument())
  fireEvent.click(getByText('Run tests'))

  await waitFor(() =>
    expect(queryByText('Status: queued')).not.toBeInTheDocument()
  )
  await waitFor(() => expect(queryByText('Status: queued')).toBeInTheDocument())

  server.close()
})

test('shows message when test times out', async () => {
  const server = setupServer(
    rest.post('https://exercism.test/submissions', (req, res, ctx) => {
      return res(
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

  const { getByText, queryByText } = render(
    <Editor
      endpoint="https://exercism.test/submissions"
      files={[{ filename: 'lasagna.rb', content: 'class Lasagna' }]}
      timeout={0}
    />
  )
  fireEvent.click(getByText('Run tests'))
  await waitFor(() => expect(queryByText('Status: queued')).toBeInTheDocument())

  await waitFor(() =>
    expect(queryByText('Status: timeout')).toBeInTheDocument()
  )

  server.close()
})

test('cancels a pending submission', async () => {
  const server = setupServer(
    rest.post('https://exercism.test/submissions', (req, res, ctx) => {
      return res(ctx.delay(1000))
    })
  )
  server.listen()

  const { getByText, queryByText } = render(
    <Editor
      endpoint="https://exercism.test/submissions"
      files={[{ filename: 'lasagna.rb', content: 'class Lasagna' }]}
    />
  )
  fireEvent.click(getByText('Run tests'))
  fireEvent.click(getByText('Cancel'))

  await waitFor(() =>
    expect(queryByText('Running tests...')).not.toBeInTheDocument()
  )

  server.close()
})

test('disables submit button unless tests passed', async () => {
  const server = setupServer(
    rest.get('https://exercism.test/test_run', (req, res, ctx) => {
      return res(
        ctx.json({
          test_run: {
            id: null,
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

  const { getByText } = render(
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
    />
  )

  expect(getByText('Submit')).toBeDisabled()
})

test('populates files', async () => {
  const server = setupServer(
    rest.get('https://exercism.test/test_run', (req, res, ctx) => {
      return res(
        ctx.json({
          test_run: {
            id: null,
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

  const { getByText } = render(
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
    />
  )

  expect(getByText('class Lasagna')).toBeInTheDocument()

  server.close()
})
