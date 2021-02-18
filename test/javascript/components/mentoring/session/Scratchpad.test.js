import React from 'react'
import userEvent from '@testing-library/user-event'
import {
  render,
  screen,
  waitForElementToBeRemoved,
} from '@testing-library/react'
import { rest } from 'msw'
import { setupServer } from 'msw/node'
import '@testing-library/jest-dom/extend-expect'
import { Scratchpad } from '../../../../../app/javascript/components/mentoring/session/Scratchpad'

test('hides local storage autosave message', async () => {
  const server = setupServer(
    rest.get('https://exercism.test/scratchpad', (req, res, ctx) => {
      return res(ctx.json({ scratchpad_page: { content_markdown: null } }))
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

test('shows errors from API', async () => {
  const server = setupServer(
    rest.get('https://exercism.test/scratchpad', (req, res, ctx) => {
      return res(ctx.json({ scratchpad_page: { content_markdown: null } }))
    }),
    rest.patch('https://exercism.test/scratchpad', (req, res, ctx) => {
      return res(
        ctx.status(404),
        ctx.json({
          error: {
            type: 'generic',
            message: 'Unable to save page',
          },
        })
      )
    })
  )
  server.listen()

  render(
    <Scratchpad endpoint="https://exercism.test/scratchpad" discussionId={1} />
  )
  await waitForElementToBeRemoved(screen.queryByText('Loading'))
  userEvent.click(screen.getByRole('button', { name: 'Save' }))

  expect(await screen.findByText('Unable to save page')).toBeInTheDocument()

  server.close()
})

test('clears errors when resubmitting', async () => {
  const server = setupServer(
    rest.get('https://exercism.test/scratchpad', (req, res, ctx) => {
      return res(ctx.json({ scratchpad_page: { content_markdown: null } }))
    }),
    rest.patch('https://exercism.test/scratchpad', (req, res, ctx) => {
      return res(
        ctx.status(404),
        ctx.json({
          error: {
            type: 'generic',
            message: 'Unable to save page',
          },
        })
      )
    })
  )
  server.listen()

  render(
    <Scratchpad endpoint="https://exercism.test/scratchpad" discussionId={1} />
  )
  await waitForElementToBeRemoved(screen.queryByText('Loading'))
  userEvent.click(screen.getByRole('button', { name: 'Save' }))

  expect(await screen.findByText('Unable to save page')).toBeInTheDocument()

  userEvent.click(screen.getByRole('button', { name: 'Save' }))

  expect(screen.queryByText('Unable to save page')).not.toBeInTheDocument()

  server.close()
})
