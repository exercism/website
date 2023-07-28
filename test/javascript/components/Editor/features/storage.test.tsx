jest.mock(
  '../../../../../app/javascript/components/editor/FileEditorCodeMirror'
)

import React from 'react'
import { waitFor, screen, act, fireEvent } from '@testing-library/react'
import { render } from '../../../test-utils'
import userEvent from '@testing-library/user-event'
import '@testing-library/jest-dom/extend-expect'
import { rest } from 'msw'
import { setupServer } from 'msw/node'
import Editor from '../../../../../app/javascript/components/Editor'
import { buildEditor } from './buildEditor'
import { expectConsoleError } from '../../../support/silence-console'

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
          links: {
            self: 'https://exercism.test/test_run',
          },
        },
      })
    )
  })
)

beforeAll(() => server.listen())
beforeEach(() => {
  localStorage.clear()
  server.resetHandlers()
})
afterAll(() => {
  server.close()
})

test('populates files', async () => {
  const props = buildEditor({
    overrides: {
      defaultFiles: [{ filename: 'lasagna.rb', content: 'class Lasagna' }],
    },
  })

  render(<Editor {...props} />)

  expect(await screen.findByText('class Lasagna')).toBeInTheDocument()
})

test('loads data from storage', async () => {
  localStorage.setItem(
    'solution-files-files',
    JSON.stringify([{ filename: 'lasagna.rb', content: 'changed' }])
  )
  const props = buildEditor({
    overrides: {
      defaultFiles: [{ filename: 'lasagna.rb', content: 'class Lasagna' }],
      autosave: { key: 'files' },
    },
  })

  render(<Editor {...props} />)

  expect(await screen.findByText('Value: changed')).toBeInTheDocument()
})

test('saves data to storage when data changed', async () => {
  jest.useFakeTimers()
  const interval = 10000
  const props = buildEditor({
    overrides: {
      defaultFiles: [{ filename: 'file', content: 'class Lasagna' }],
      autosave: { key: 'files', saveInterval: interval },
    },
  })

  render(<Editor {...props} />)

  fireEvent.change(screen.getByTestId('editor-value'), {
    target: { value: 'code' },
  })
  act(() => {
    jest.advanceTimersByTime(interval + 10)
  })

  expect(localStorage.getItem('solution-files-files')).toEqual(
    JSON.stringify([{ filename: 'file', content: 'code' }])
  )

  jest.useRealTimers()
})

test('revert to last iteration fails', async () => {
  await expectConsoleError(async () => {
    server.use(
      rest.get('https://exercism.test/files', (req, res, ctx) => {
        return res(
          ctx.status(400),
          ctx.json({
            error: { type: 'generic', message: 'Unable to retrieve files' },
          })
        )
      })
    )
    const props = buildEditor({
      overrides: {
        defaultFiles: [{ filename: 'file', content: 'class Lasagna' }],
        defaultSubmissions: [
          {
            links: {
              testRun: 'https://exercism.test/test_run',
              lastIterationFiles: 'https://exercism.test/files',
            },
          },
        ],
        autosave: { saveInterval: 100000 },
      },
    })

    render(<Editor {...props} />)

    userEvent.click(screen.getByAltText('Open more options'))
    userEvent.click(
      await screen.findByRole('button', { name: /revert to last iteration/i })
    )

    expect(
      await screen.findByText('Error: Unable to retrieve files')
    ).toBeInTheDocument()
  })
})

test('revert to exercise start fails', async () => {
  await expectConsoleError(async () => {
    server.use(
      rest.get('https://exercism.test/files', (req, res, ctx) => {
        return res(
          ctx.status(400),
          ctx.json({
            error: { type: 'generic', message: 'Unable to retrieve files' },
          })
        )
      })
    )
    const props = buildEditor({
      overrides: {
        defaultFiles: [{ filename: 'file', content: 'class Lasagna' }],
        defaultSubmissions: [
          {
            links: {
              testRun: 'https://exercism.test/test_run',
              initialFiles: 'https://exercism.test/files',
            },
          },
        ],
        autosave: { saveInterval: 100000 },
      },
    })

    render(<Editor {...props} />)

    userEvent.click(screen.getByAltText('Open more options'))
    userEvent.click(
      await screen.findByRole('button', { name: /revert to exercise start/i })
    )

    expect(
      await screen.findByText('Error: Unable to retrieve files')
    ).toBeInTheDocument()
  })
})
