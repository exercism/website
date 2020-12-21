jest.mock('../../../../../app/javascript/components/editor/FileEditor')

import React from 'react'
import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import '@testing-library/jest-dom/extend-expect'
import { rest } from 'msw'
import { setupServer } from 'msw/node'
import { Editor } from '../../../../../app/javascript/components/Editor'

test('switches tabs', async () => {
  render(
    <Editor
      files={[{ filename: 'lasagna.rb', content: 'class Lasagna' }]}
      instructions={{
        overview: '',
        generalHints: [],
        tasks: [],
      }}
    />
  )

  userEvent.click(screen.getByRole('tab', { name: 'Results' }))

  expect(
    await screen.findByRole('tab', { name: 'Results', selected: true })
  ).toBeInTheDocument()
  expect(
    await screen.findByRole('tab', { name: 'Instructions', selected: false })
  ).toBeInTheDocument()
  expect(
    await screen.findByRole('tabpanel', { name: 'Results' })
  ).toBeInTheDocument()
  expect(
    screen.queryByRole('tabpanel', { name: 'Instructions' })
  ).not.toBeInTheDocument()
})

test('opens instructions tab by default', async () => {
  render(
    <Editor
      files={[{ filename: 'file', content: 'file' }]}
      instructions={{ overview: '', generalHints: [], tasks: [] }}
    />
  )

  expect(
    screen.getByRole('tab', { name: 'Instructions', selected: true })
  ).toBeInTheDocument()
  expect(
    screen.getByRole('tabpanel', { name: 'Instructions' })
  ).toBeInTheDocument()
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

  render(
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

  expect(
    await screen.findByRole('tab', { name: 'Results', selected: true })
  ).toBeInTheDocument()
  expect(
    await screen.findByRole('tabpanel', { name: 'Results' })
  ).toBeInTheDocument()

  server.close()
})
