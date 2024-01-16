jest.mock(
  '../../../../../app/javascript/components/editor/FileEditorCodeMirror'
)

import React from 'react'
import { screen } from '@testing-library/react'
import { render } from '../../../test-utils'
import userEvent from '@testing-library/user-event'
import '@testing-library/jest-dom/extend-expect'
import { rest } from 'msw'
import { setupServer } from 'msw/node'
import Editor from '../../../../../app/javascript/components/Editor'
import { awaitPopper } from '../../../support/await-popper'
import { buildEditor } from './buildEditor'

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
beforeEach(() => server.resetHandlers())
afterAll(() => server.close())

test('switches tabs', async () => {
  const props = buildEditor()

  render(<Editor {...props} />)
  userEvent.click(await screen.findByRole('tab', { name: 'Results' }))

  expect(
    await screen.findByRole('tab', { name: 'Results', selected: true })
  ).toBeInTheDocument()
  expect(
    screen.getByRole('tab', { name: 'Instructions', selected: false })
  ).toBeInTheDocument()
  expect(screen.getByRole('tabpanel', { name: 'Results' })).toBeInTheDocument()
  expect(
    screen.queryByRole('tabpanel', { name: 'Instructions' })
  ).not.toBeInTheDocument()
})

test('opens instructions tab by default', async () => {
  const props = buildEditor()

  render(<Editor {...props} />)

  expect(
    screen.getByRole('tab', { name: 'Instructions', selected: true })
  ).toBeInTheDocument()
  expect(
    screen.getByRole('tabpanel', { name: 'Instructions' })
  ).toBeInTheDocument()
})

test('opens results tab by default if tests have previously ran', async () => {
  const props = buildEditor({
    overrides: {
      defaultSubmissions: [
        {
          links: {
            testRun: 'https://exercism.test/test_run',
          },
        },
      ],
    },
  })

  render(<Editor {...props} />)

  expect(
    await screen.findByRole('tab', { name: 'Results', selected: true })
  ).toBeInTheDocument()
  expect(
    await screen.findByRole('tabpanel', { name: 'Results' })
  ).toBeInTheDocument()
})
