import React from 'react'
import { setConsole } from 'react-query'
import { render, screen, fireEvent, waitFor } from '@testing-library/react'
import { rest } from 'msw'
import { setupServer } from 'msw/node'
import '@testing-library/jest-dom/extend-expect'
import { DiscussionList } from '../../../../../app/javascript/components/mentoring/inbox/DiscussionList.jsx'
import { TestQueryCache } from '../../../support/TestQueryCache'

const server = setupServer(
  rest.get('https://exercism.test/conversations', (req, res, ctx) => {
    return res(ctx.status(500, 'Internal server error'))
  })
)

// Don't output logging from react-query
setConsole({
  log: () => {},
  warn: () => {},
  error: () => {},
})

beforeAll(() => server.listen())
afterEach(() => server.resetHandlers())
afterAll(() => server.close())

test('allow retry after loading error', async () => {
  const setPage = jest.fn()

  render(
    <DiscussionList
      request={{
        endpoint: 'https://exercism.test/conversations',
        query: { page: 2 },
        options: { retry: false },
      }}
      setPage={setPage}
    />
  )

  await waitFor(() => expect(screen.getByText('Retry')).toBeInTheDocument())

  server.use(
    rest.get('https://exercism.test/conversations', (req, res, ctx) => {
      return res(
        ctx.json({
          results: [
            {
              trackTitle: 'Ruby',
              exerciseTitle: 'Bob',
              isStarred: false,
              isNewSubmission: false,
              haveMentoredPreviously: false,
            },
          ],
          meta: { totalPages: 2 },
        })
      )
    })
  )

  fireEvent.click(screen.getByText('Retry'))

  await waitFor(() => expect(screen.getByText('on Bob')).toBeInTheDocument())
  expect(screen.queryByText('Retry')).not.toBeInTheDocument()
})

test('hides pagination when totalPages < 1', async () => {
  const setPage = jest.fn()
  const server = setupServer(
    rest.get('https://exercism.test/conversations', (req, res, ctx) => {
      return res(
        ctx.json({
          results: [
            {
              trackTitle: 'Ruby',
              exerciseTitle: 'Bob',
              isStarred: false,
              isNewSubmission: false,
              haveMentoredPreviously: false,
            },
          ],
          meta: {
            totalPages: 1,
          },
        })
      )
    })
  )
  server.listen()

  render(
    <TestQueryCache>
      <DiscussionList
        request={{
          endpoint: 'https://exercism.test/conversations',
          query: {},
          options: { retry: false },
        }}
        setPage={setPage}
      />
    </TestQueryCache>
  )

  expect(await screen.findByText('on Bob')).toBeInTheDocument()
  await waitFor(() =>
    expect(
      screen.queryByRole('button', { name: 'Go to first page' })
    ).not.toBeInTheDocument()
  )

  server.close()
})
