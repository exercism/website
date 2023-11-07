import React from 'react'
import { render, screen } from '@testing-library/react'
import { rest } from 'msw'
import { setupServer } from 'msw/node'
import '@testing-library/jest-dom/extend-expect'
import { DiscussionList } from '../../../../../app/javascript/components/mentoring/inbox/DiscussionList'

const server = setupServer(
  rest.get('https://exercism.test/conversations', (req, res, ctx) => {
    return res(ctx.status(500, 'Internal server error'))
  })
)

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

  const text = await screen.findByText('Retry')
  expect(text).toBeInTheDocument()
})
