import React from 'react'
import { screen, waitForElementToBeRemoved } from '@testing-library/react'
import { render } from '../../../test-utils'
import { rest } from 'msw'
import { setupServer } from 'msw/node'
import '@testing-library/jest-dom/extend-expect'
import { IterationFiles } from '../../../../../app/javascript/components/mentoring/session/IterationFiles'
import userEvent from '@testing-library/user-event'
import { silenceConsole } from '../../../support/silence-console'

test('shows files in tabs', async () => {
  const files = [
    {
      filename: 'bob.rb',
      content: 'class Bob\nend',
      digest: '1',
    },
    {
      filename: 'bob_test.rb',
      content: 'class BobTest\nend',
      digest: '2',
    },
  ]
  const server = setupServer(
    rest.get('https://exercism.test/files', (req, res, ctx) => {
      return res(ctx.json({ files: files }))
    })
  )
  server.listen()

  render(
    <IterationFiles endpoint="https://exercism.test/files" language="ruby" />
  )
  await waitForElementToBeRemoved(screen.getByText('Loading'))
  userEvent.click(await screen.findByRole('tab', { name: 'bob_test.rb' }))

  expect(screen.getByText('BobTest')).toBeInTheDocument()

  server.close()
})

test('shows errors from API', async () => {
  silenceConsole()
  const server = setupServer(
    rest.get('https://exercism.test/files', (req, res, ctx) => {
      return res(
        ctx.status(422),
        ctx.json({ error: { message: 'Unable to load files' } })
      )
    })
  )
  server.listen()

  render(
    <IterationFiles endpoint="https://exercism.test/files" language="ruby" />
  )

  expect(await screen.findByText('Unable to load files')).toBeInTheDocument()

  server.close()
})

test('shows generic error message for unexpected errors', async () => {
  silenceConsole()
  const server = setupServer(
    rest.get('https://exercism.test/files', (req, res, ctx) => {
      return res(ctx.status(404))
    })
  )
  server.listen()

  render(<IterationFiles endpoint="weirdendpoint" language="ruby" />)

  expect(await screen.findByText('Unable to load files')).toBeInTheDocument()

  server.close()
})
