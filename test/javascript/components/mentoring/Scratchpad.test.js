import React from 'react'
import {
  render,
  screen,
  waitForElementToBeRemoved,
} from '@testing-library/react'
import { rest } from 'msw'
import { setupServer } from 'msw/node'
import '@testing-library/jest-dom/extend-expect'
import { Scratchpad } from '../../../../app/javascript/components/mentoring/Scratchpad'

test('hides local storage autosave message', async () => {
  const server = setupServer(
    rest.get('https://exercism.test/scratchpad', (req, res, ctx) => {
      return res(ctx.json(null))
    })
  )
  server.listen()

  render(
    <Scratchpad endpoint="https://exercism.test/scratchpad" discussionId={1} />
  )
  await waitForElementToBeRemoved(screen.queryByText('Loading'))

  expect(screen.queryByText(/Autosaved/)).not.toBeInTheDocument()

  server.close()
})
