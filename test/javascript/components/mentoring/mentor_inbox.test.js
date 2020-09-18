import React from 'react'
import { render, screen, fireEvent, waitFor } from '@testing-library/react'
import { rest } from 'msw'
import { setupServer } from 'msw/node'
import '@testing-library/jest-dom/extend-expect'
import { MentorInbox } from '../../../../app/javascript/components/mentoring/mentor_inbox'

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
            isNewIteration: false,
            haveMentoredPreviously: false,
          },
        ],
        meta: { total: 2 },
      })
    )
  })
)

beforeAll(() => server.listen())
afterEach(() => server.resetHandlers())
afterAll(() => server.close())

test('page is set to 1 automatically', async () => {
  render(
    <MentorInbox
      tracksRequest={{ endpoint: 'https://exercism.test/tracks' }}
      conversationsRequest={{ endpoint: 'https://exercism.test/conversations' }}
      sortOptions={[]}
    />
  )

  await waitFor(() => expect(screen.getByText('First')).toBeDisabled())
})

test('page is reset to 1 when switching tracks', async () => {
  render(
    <MentorInbox
      tracksRequest={{ endpoint: 'https://exercism.test/tracks' }}
      conversationsRequest={{
        endpoint: 'https://exercism.test/conversations',
        query: { page: 2 },
      }}
      sortOptions={[]}
    />
  )

  await waitFor(() =>
    fireEvent.change(screen.getByLabelText('Track'), { target: { value: '2' } })
  )
  await waitFor(() => expect(screen.getByText('First')).toBeDisabled())
})
