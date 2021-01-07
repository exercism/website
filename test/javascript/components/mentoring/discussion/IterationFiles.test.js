import React from 'react'
import {
  render,
  screen,
  waitForElementToBeRemoved,
} from '@testing-library/react'
import { rest } from 'msw'
import { setupServer } from 'msw/node'
import '@testing-library/jest-dom/extend-expect'
import { IterationFiles } from '../../../../../app/javascript/components/mentoring/discussion/IterationFiles'
import userEvent from '@testing-library/user-event'

test('shows files in tabs', async () => {
  const files = [
    {
      filename: 'bob.rb',
      content: 'class Bob\nend',
    },
    {
      filename: 'bob_test.rb',
      content: 'class BobTest\nend',
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

  expect(
    screen.getByRole('cell', { name: 'class BobTest' })
  ).toBeInTheDocument()

  server.close()
})
