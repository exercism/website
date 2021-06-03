import React from 'react'
import { setConsole } from 'react-query'
import { render, screen, waitFor } from '@testing-library/react'
import { rest } from 'msw'
import { setupServer } from 'msw/node'
import '@testing-library/jest-dom/extend-expect'
import { DiscussionList } from '../../../../../app/javascript/components/mentoring/inbox/DiscussionList'

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
      status="error"
      setPage={setPage}
    />
  )

  await waitFor(() => expect(screen.getByText('Retry')).toBeInTheDocument())
})
