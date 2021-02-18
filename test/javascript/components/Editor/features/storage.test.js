jest.mock('../../../../../app/javascript/components/editor/FileEditor')

import React from 'react'
import { render, fireEvent, waitFor } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { rest } from 'msw'
import { setupServer } from 'msw/node'
import { Editor } from '../../../../../app/javascript/components/Editor'

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
      assignment={{
        overview: '',
        generalHints: [],
        tasks: [],
      }}
    />
  )

  await waitFor(() => {
    expect(getByText('class Lasagna')).toBeInTheDocument()
  })

  server.close()
})

test('loads data from storage', async () => {
  localStorage.setItem(
    'solution-files-files',
    JSON.stringify([{ filename: 'file', content: 'class' }])
  )

  const { queryByText } = render(
    <Editor
      storageKey="files"
      files={[{ filename: 'file', content: '' }]}
      assignment={{ overview: '', generalHints: [], tasks: [] }}
    />
  )

  expect(queryByText('Value: class')).toBeInTheDocument()

  localStorage.clear()
})

test('saves data to storage when data changed', async () => {
  jest.useFakeTimers()
  const { getByTestId } = render(
    <Editor
      storageKey="files"
      files={[{ filename: 'file', content: '' }]}
      assignment={{ overview: '', generalHints: [], tasks: [] }}
    />
  )

  fireEvent.change(getByTestId('editor-value'), { target: { value: 'code' } })
  await waitFor(() => {
    jest.runOnlyPendingTimers()
  })

  expect(localStorage.getItem('solution-files-files')).toEqual(
    JSON.stringify([{ filename: 'file', content: 'code' }])
  )

  localStorage.clear()
})

test('revert to last submission', async () => {
  jest.useFakeTimers()
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
    })
  )
  server.listen()

  const { getByTitle, getByText, queryByText, getByTestId } = render(
    <Editor
      endpoint="https://exercism.test/submissions"
      files={[{ filename: 'file', content: 'other' }]}
      assignment={{ overview: '', generalHints: [], tasks: [] }}
    />
  )

  fireEvent.change(getByTestId('editor-value'), { target: { value: 'file' } })
  await waitFor(() => {
    jest.runOnlyPendingTimers()
  })
  fireEvent.click(getByText('Run Tests'))
  await waitFor(() =>
    expect(
      queryByText("We've queued your code and will run it shortly.")
    ).toBeInTheDocument()
  )
  fireEvent.change(getByTestId('editor-value'), { target: { value: 'class' } })
  await waitFor(() => {
    jest.runOnlyPendingTimers()
  })
  fireEvent.click(getByTitle('Open more options'))
  fireEvent.click(getByText('Revert to last iteration submission'))
  await waitFor(() => {
    jest.runOnlyPendingTimers()
  })

  await waitFor(() => expect(queryByText('Value: file')).toBeInTheDocument())
  fireEvent.click(getByTitle('Open more options'))
  await waitFor(() =>
    expect(getByText('Revert to last iteration submission')).toBeDisabled()
  )

  localStorage.clear()
  server.close()
})

test('revert to exercise start', async () => {
  const server = setupServer(
    rest.get('https://exercism.test/files', (req, res, ctx) => {
      return res(
        ctx.json({
          files: [{ filename: 'file', content: 'class' }],
        })
      )
    }),
    rest.get('https://exercism.test/test_run', (req, res, ctx) => {
      return res(ctx.json({ test_run: null }))
    })
  )
  server.listen()

  const { getByTitle, getByText, queryByText } = render(
    <Editor
      files={[{ filename: 'file', content: 'file' }]}
      initialSubmission={{
        uuid: '123',
        testsStatus: 'failed',
        links: {
          testRun: 'https://exercism.test/test_run',
          initialFiles: 'https://exercism.test/files',
        },
      }}
      assignment={{
        overview: '',
        generalHints: [],
        tasks: [],
      }}
    />
  )

  fireEvent.click(getByTitle('Open more options'))
  fireEvent.click(getByText('Revert to exercise start'))

  await waitFor(() =>
    expect(queryByText('Reverting to exercise start...')).toBeInTheDocument()
  )
  await waitFor(() => expect(queryByText('Value: class')).toBeInTheDocument())
  await waitFor(() =>
    expect(
      queryByText('Reverting to exercise start...')
    ).not.toBeInTheDocument()
  )

  server.close()
})

test('revert to exercise start fails', async () => {
  const server = setupServer(
    rest.get('https://exercism.test/files', (req, res, ctx) => {
      return res(
        ctx.status(400),
        ctx.json({
          error: { type: 'generic', message: 'Unable to retrieve files' },
        })
      )
    }),
    rest.get('https://exercism.test/test_run', (req, res, ctx) => {
      return res(ctx.json({ test_run: null }))
    })
  )
  server.listen()

  const { getByTitle, getByText, queryByText } = render(
    <Editor
      files={[{ filename: 'file', content: 'file' }]}
      initialSubmission={{
        uuid: '123',
        testsStatus: 'failed',
        links: {
          testRun: 'https://exercism.test/test_run',
          initialFiles: 'https://exercism.test/files',
        },
      }}
      assignment={{
        overview: '',
        generalHints: [],
        tasks: [],
      }}
    />
  )

  fireEvent.click(getByTitle('Open more options'))
  fireEvent.click(getByText('Revert to exercise start'))

  await waitFor(() =>
    expect(queryByText('Reverting to exercise start...')).toBeInTheDocument()
  )
  await waitFor(() =>
    expect(queryByText('Unable to retrieve files')).toBeInTheDocument()
  )

  server.close()
})
