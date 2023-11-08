import React from 'react'
import { render, screen, waitFor, act } from '@testing-library/react'
import { rest } from 'msw'
import { setupServer } from 'msw/node'
import '@testing-library/jest-dom/extend-expect'
import { StartDiscussionPanel } from '../../../../../app/javascript/components/mentoring/request/StartDiscussionPanel'
import { silenceConsole } from '../../../support/silence-console'
import { stubRange } from '../../../support/code-mirror-helpers'
import userEvent from '@testing-library/user-event'
import { TestQueryCache } from '../../../support/TestQueryCache'
stubRange()

test('disables button while locking mentoring request', async () => {
  const request = {
    links: {
      discussion: 'https://exercism.test/discussion',
    },
  }
  const links = {
    mentoringDocs: 'https://exercism.test/docs/mentoring',
  }
  const iterations = [{ idx: 1 }]
  const server = setupServer(
    rest.post('https://exercism.test/discussion', (req, res, ctx) => {
      return res(ctx.status(200), ctx.json({ discussion: {} }))
    })
  )
  server.listen()

  render(
    <TestQueryCache>
      <StartDiscussionPanel
        request={request}
        iterations={iterations}
        setDiscussion={jest.fn()}
        links={links}
      />
    </TestQueryCache>
  )
  await act(async () => userEvent.click(screen.getByTestId('markdown-editor')))
  const textarea = screen.getByRole('textbox')
  await act(async () => userEvent.type(textarea, 'Hello'))
  await act(async () =>
    userEvent.click(screen.getByRole('button', { name: 'Send' }))
  )

  await waitFor(() =>
    expect(screen.getByRole('button', { name: 'Send' })).toBeDisabled()
  )

  server.close()
})

test('shows API errors', async () => {
  silenceConsole()
  const request = {
    links: {
      discussion: 'https://exercism.test/discussion',
    },
  }
  const links = {
    mentoringDocs: 'https://exercism.test/docs/mentoring',
  }
  const iterations = [{ idx: 1 }]
  const server = setupServer(
    rest.post('https://exercism.test/discussion', (req, res, ctx) => {
      return res(
        ctx.status(422),
        ctx.json({
          error: {
            message: 'Unable to start discussion',
          },
        })
      )
    })
  )
  server.listen()

  render(
    <TestQueryCache>
      <StartDiscussionPanel
        request={request}
        iterations={iterations}
        links={links}
      />
    </TestQueryCache>
  )
  await act(async () => userEvent.click(screen.getByTestId('markdown-editor')))
  const textarea = screen.getByRole('textbox')
  await act(async () => userEvent.type(textarea, 'Hello'))
  await act(async () =>
    userEvent.click(screen.getByRole('button', { name: 'Send' }))
  )

  expect(
    await screen.findByText('Unable to start discussion')
  ).toBeInTheDocument()

  server.close()
})

test('shows generic errors', async () => {
  silenceConsole()
  const request = {
    links: {
      discussion: 'https://exercism.test/discussion',
    },
  }
  const links = {
    mentoringDocs: 'https://exercism.test/docs/mentoring',
  }
  const iterations = [{ idx: 1 }]

  render(
    <TestQueryCache>
      <StartDiscussionPanel
        request={request}
        iterations={iterations}
        links={links}
      />
    </TestQueryCache>
  )
  await act(async () => userEvent.click(screen.getByTestId('markdown-editor')))
  const textarea = screen.getByRole('textbox')
  await act(async () => userEvent.type(textarea, 'Hello'))
  await act(async () =>
    userEvent.click(screen.getByRole('button', { name: 'Send' }))
  )

  expect(
    await screen.findByText('Unable to start discussion')
  ).toBeInTheDocument()
})
