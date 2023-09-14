import React from 'react'
import { screen, waitFor } from '@testing-library/react'
import { render } from '../../test-utils'
import { rest } from 'msw'
import { setupServer } from 'msw/node'
import '@testing-library/jest-dom/extend-expect'
import { Inbox } from '@/components/mentoring'
import userEvent from '@testing-library/user-event'
import { expectConsoleError } from '../../support/silence-console'
import { awaitPopper } from '../../support/await-popper'
import { queryClient } from '../../setupTests'

let server = setupServer(
  rest.get('https://exercism.test/tracks', (req, res, ctx) => {
    return res(
      ctx.json([
        { slug: 'ruby', title: 'Ruby' },
        { slug: 'go', title: 'Go' },
      ])
    )
  }),
  rest.get('https://exercism.test/conversations', (req, res, ctx) => {
    return res(
      ctx.json({
        results: [
          {
            track: {
              title: 'Ruby',
            },
            exercise: {
              title: 'Lasagna',
            },
            student: {
              avatarUrl: 'http://exercism.org/avatar',
            },
            isStarred: false,
            isNewSubmission: false,
            haveMentoredPreviously: false,
            links: {},
            student: {
              avatarUrl: '',
            },
            exercise: {
              title: 'Lasagna',
            },
            isStarred: false,
            isNewSubmission: false,
            haveMentoredPreviously: false,
            links: {
              self: '',
            },
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
      discussionsRequest={{ endpoint: 'https://exercism.test/conversations' }}
      sortOptions={[{ label: 'Sort by Newest First', value: 'newest_first' }]}
    />
  )

  await waitFor(() => expect(screen.getByText('First')).toBeDisabled())
})

test('page is reset to 1 when switching tracks', async () => {
  await awaitPopper()

  await expectConsoleError(async () => {
    render(
      <Inbox
        tracksRequest={{ endpoint: 'https://exercism.test/tracks' }}
        discussionsRequest={{
          endpoint: 'https://exercism.test/conversations',
          query: { page: 2 },
        }}
        sortOptions={[{ label: 'Sort by Newest First', value: 'newest_first' }]}
      />
    )

    userEvent.click(await screen.findByRole('button', { name: /Ruby/ }))

    userEvent.click(screen.getByRole('radio', { name: /Go/ }))

    await waitFor(() => expect(screen.getByText('First')).toBeDisabled())

    queryClient.cancelQueries()
    await awaitPopper()
  })
})
