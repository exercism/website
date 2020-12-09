jest.mock('../../../app/javascript/components/editor/FileEditor')

import React from 'react'
import { render, fireEvent, waitFor } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { rest } from 'msw'
import { setupServer } from 'msw/node'
import { Editor } from '../../../app/javascript/components/Editor'

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
  fireEvent.click(getByText('Run Tests'))
  await waitFor(() =>
    expect(
      queryByText("We've queued your code and will run it shortly.")
    ).toBeInTheDocument()
  )
  fireEvent.click(getByText('Run Tests'))

  await waitFor(() =>
    expect(
      queryByText("We've queued your code and will run it shortly.")
    ).not.toBeInTheDocument()
  )
  await waitFor(() =>
    expect(
      queryByText("We've queued your code and will run it shortly.")
    ).toBeInTheDocument()
  )

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
  fireEvent.click(getByText('Run Tests'))
  await waitFor(() =>
    expect(
      queryByText("We've queued your code and will run it shortly.")
    ).toBeInTheDocument()
  )

  await waitFor(() =>
    expect(queryByText('Tests timed out')).toBeInTheDocument()
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
  fireEvent.click(getByText('Run Tests'))
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

  await waitFor(() => {
    expect(getByText('Submit')).toBeDisabled()
  })

  server.close()
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

  await waitFor(() => {
    expect(getByText('class Lasagna')).toBeInTheDocument()
  })

  server.close()
})

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

test('change theme', async () => {
  const { getByTitle, getByLabelText, queryByText } = render(
    <Editor files={[{ filename: 'lasagna.rb', content: 'class Lasagna' }]} />
  )

  fireEvent.click(getByTitle('Settings'))
  fireEvent.change(getByLabelText('Theme'), { target: { value: 'vs-dark' } })

  await waitFor(() => {
    expect(queryByText('Theme: vs-dark')).toBeInTheDocument()
  })
})

test('change keybindings', async () => {
  const { getByTitle, getByLabelText, queryByText } = render(
    <Editor files={[{ filename: 'lasagna.rb', content: 'class Lasagna' }]} />
  )

  fireEvent.click(getByTitle('Settings'))
  fireEvent.change(getByLabelText('Keybindings'), { target: { value: 'vim' } })

  await waitFor(() => {
    expect(queryByText('Keybindings: vim')).toBeInTheDocument()
  })
})

test('change wrapping', async () => {
  const { getByTitle, getByLabelText, queryByText } = render(
    <Editor files={[{ filename: 'lasagna.rb', content: 'class Lasagna' }]} />
  )

  fireEvent.click(getByTitle('Settings'))
  fireEvent.change(getByLabelText('Wrap'), { target: { value: 'off' } })

  await waitFor(() => {
    expect(queryByText('Wrap: off')).toBeInTheDocument()
  })
})

test('loads data from storage', async () => {
  localStorage.setItem(
    'files',
    JSON.stringify([{ filename: 'file', content: 'class' }])
  )

  const { queryByText } = render(
    <Editor files={[{ filename: 'file', content: '' }]} />
  )

  expect(queryByText('Value: class')).toBeInTheDocument()

  localStorage.clear()
})

test('saves data to storage when data changed', async () => {
  jest.useFakeTimers()
  const { getByTestId } = render(
    <Editor files={[{ filename: 'file', content: '' }]} />
  )

  fireEvent.change(getByTestId('editor-value'), { target: { value: 'code' } })
  await waitFor(() => {
    jest.runOnlyPendingTimers()
  })

  expect(localStorage.getItem('files')).toEqual(
    JSON.stringify([{ filename: 'file', content: 'code' }])
  )

  localStorage.clear()
})

test('revert to last submission', async () => {
  jest.useFakeTimers()
  localStorage.setItem(
    'files',
    JSON.stringify([{ filename: 'file', content: 'class' }])
  )

  const { getByTitle, getByText, queryByText } = render(
    <Editor files={[{ filename: 'file', content: 'file' }]} />
  )

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
})
