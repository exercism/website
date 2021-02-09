import React from 'react'
import { render, screen, fireEvent, waitFor } from '@testing-library/react'
import { rest } from 'msw'
import { setupServer } from 'msw/node'
import '@testing-library/jest-dom/extend-expect'
import { Inbox } from '../../../../app/javascript/components/mentoring/Inbox.jsx'

const server = setupServer(
  rest.get('https://exercism.test/tracks', (req, res, ctx) => {
    return res(ctx.json([{ id: 2 }]))
  }),
  rest.get('https://exercism.test/conversations', (req, res, ctx) => {
    return res(
      ctx.json({
        results: [
          {
            trackTitle: 'Ruby',
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

beforeAll(() => server.listen())
afterEach(() => server.resetHandlers())
afterAll(() => server.close())

test('page is set to 1 automatically', async () => {
  render(
    <Inbox
      tracksRequest={{ endpoint: 'https://exercism.test/tracks' }}
      conversationsRequest={{ endpoint: 'https://exercism.test/conversations' }}
      sortOptions={[]}
    />
  )

  await waitFor(() => expect(screen.getByText('First')).toBeDisabled())
})

test('page is reset to 1 when switching tracks', async () => {
  render(
    <Inbox
      tracksRequest={{ endpoint: 'https://exercism.test/tracks' }}
      conversationsRequest={{
        endpoint: 'https://exercism.test/conversations',
        query: { page: 2 },
      }}
      sortOptions={[]}
    />
  )

  await waitFor(() =>
    fireEvent.change(screen.getByTestId('track-filter'), {
      target: { value: '2' },
    })
  )
  await waitFor(() => expect(screen.getByText('First')).toBeDisabled())
})
