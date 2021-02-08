import React from 'react'
import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { rest } from 'msw'
import { setupServer } from 'msw/node'
import '@testing-library/jest-dom/extend-expect'
import { FinishMentorDiscussionModal } from '../../../../app/javascript/components/modals/FinishMentorDiscussionModal'
import { silenceConsole } from '../../support/silence-console'

test('disables buttons when loading', async () => {
  const server = setupServer(
    rest.patch('https://exercism.test/end', (req, res, ctx) => {
      return res(ctx.status(200), ctx.json({ discussion: {} }))
    })
  )
  server.listen()

  render(
    <FinishMentorDiscussionModal
      open
      endpoint="https://exercism.test/end"
      ariaHideApp={false}
      onSuccess={() => {}}
    />
  )
  userEvent.click(screen.getByRole('button', { name: 'End discussion F3' }))

  expect(
    await screen.findByRole('button', { name: 'End discussion F3' })
  ).toBeDisabled()
  expect(screen.getByRole('button', { name: 'Cancel F2' })).toBeDisabled()

  server.close()
})

test('shows loading message when loading', async () => {
  const server = setupServer(
    rest.patch('https://exercism.test/end', (req, res, ctx) => {
      return res(ctx.status(200), ctx.json({ discussion: {} }))
    })
  )
  server.listen()

  render(
    <FinishMentorDiscussionModal
      open
      endpoint="https://exercism.test/end"
      ariaHideApp={false}
      onSuccess={() => {}}
    />
  )
  userEvent.click(screen.getByRole('button', { name: 'End discussion F3' }))

  expect(await screen.findByText('Loading')).toBeInTheDocument()

  server.close()
})

test('shows API errors', async () => {
  silenceConsole()
  const server = setupServer(
    rest.patch('https://exercism.test/end', (req, res, ctx) => {
      return res(
        ctx.status(422),
        ctx.json({ error: { message: 'Unable to end discussion' } })
      )
    })
  )
  server.listen()

  render(
    <FinishMentorDiscussionModal
      open
      endpoint="https://exercism.test/end"
      ariaHideApp={false}
      onSuccess={() => {}}
    />
  )
  userEvent.click(screen.getByRole('button', { name: 'End discussion F3' }))

  expect(
    await screen.findByText('Unable to end discussion')
  ).toBeInTheDocument()

  server.close()
})

test('shows generic error', async () => {
  silenceConsole()

  render(
    <FinishMentorDiscussionModal
      open
      endpoint="https://exercism.test/end"
      ariaHideApp={false}
      onSuccess={() => {}}
    />
  )
  userEvent.click(screen.getByRole('button', { name: 'End discussion F3' }))

  expect(
    await screen.findByText('Unable to end discussion')
  ).toBeInTheDocument()
})
