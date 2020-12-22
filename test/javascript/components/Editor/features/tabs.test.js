jest.mock('../../../../../app/javascript/components/editor/FileEditor')

import React from 'react'
import { render, fireEvent, waitFor } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { rest } from 'msw'
import { setupServer } from 'msw/node'
import { Editor } from '../../../../../app/javascript/components/Editor'

test('switches tabs', async () => {
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
      files={[{ filename: 'lasagna.rb', content: 'class Lasagna' }]}
      initialSubmission={{
        uuid: '123',
        testsStatus: 'queued',
        links: {
          testRun: 'https://exercism.test/test_run',
        },
      }}
      instructions={{
        overview: '',
        generalHints: [],
        tasks: [],
      }}
    />
  )

  fireEvent.click(getByText('Results'))

  await waitFor(() => {
    expect(
      queryByText("We've queued your code and will run it shortly.")
    ).toBeInTheDocument()
  })
  await waitFor(() => {
    expect(queryByText('Introduction')).not.toBeInTheDocument()
  })

  server.close()
})
test('opens instructions tab by default', async () => {
  const { queryByText } = render(
    <Editor
      files={[{ filename: 'file', content: 'file' }]}
      instructions={{ overview: '', generalHints: [], tasks: [] }}
    />
  )

  expect(queryByText('Introduction')).toBeInTheDocument()

  localStorage.clear()
})

test('opens results tab by default if tests have previously ran', async () => {
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

  const { queryByText } = render(
    <Editor
      files={[{ filename: 'lasagna.rb', content: 'class Lasagna' }]}
      initialSubmission={{
        uuid: '123',
        testsStatus: 'queued',
        links: {
          testRun: 'https://exercism.test/test_run',
        },
      }}
      instructions={{
        overview: '',
        generalHints: [],
        tasks: [],
      }}
    />
  )
  await waitFor(() =>
    expect(
      queryByText("We've queued your code and will run it shortly.")
    ).toBeInTheDocument()
  )
  expect(queryByText('Introduction')).not.toBeInTheDocument()

  server.close()
})
