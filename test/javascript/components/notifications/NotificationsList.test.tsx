import React from 'react'
import {
  screen,
  waitFor,
  waitForElementToBeRemoved,
} from '@testing-library/react'
import { render } from '../../test-utils'
import '@testing-library/jest-dom/extend-expect'
import { default as NotificationsList } from '@/components/notifications/NotificationsList'
import { rest } from 'msw'
import { setupServer } from 'msw/node'
import { deferred } from '../../support/deferred'
import userEvent from '@testing-library/user-event'
import { expectConsoleError } from '../../support/silence-console'

const server = setupServer(
  rest.get('https://exercism.test/notifications', (req, res, ctx) => {
    return res(
      ctx.status(200),
      ctx.json({
        results: [
          {
            uuid: 'notification',
            url: 'https://exercism.test/notifications/notification',
            text: 'A student has replied to your post',
            created_at: new Date().toISOString(),
            image_type: 'avatar',
            image_url: 'https://exercism.test/students/1/avatar.png',
          },
        ],
        meta: {
          currentPage: 1,
          totalCount: 1,
          totalPages: 1,
          links: {
            all: 'https://exercism.test/notifications',
          },
          unreadCount: 0,
        },
      })
    )
  }),
  rest.patch(
    'https://exercism.test/notifications/mark_as_read',
    (req, res, ctx) => {
      return res(ctx.status(200), ctx.json({}))
    }
  )
)

beforeAll(() => {
  server.listen()
})
afterEach(() => {
  server.resetHandlers()
})
afterAll(() => {
  server.close()
})

test('shows results overlay when loading data', async () => {
  jest.useFakeTimers()
  const { promise } = deferred()
  server.use(
    rest.get('https://exercism.test/notifications', (req, res, ctx) => {
      return promise.then(() => {
        res(ctx.json({}))
      })
    })
  )

  render(
    <NotificationsList
      request={{ endpoint: 'https://exercism.test/notifications', options: {} }}
      links={{ markAsRead: 'https://exercism.test/notifications/mark_as_read' }}
    />
  )

  expect(screen.getByAltText(/loading data/i)).toBeInTheDocument()

  jest.useRealTimers()
})

test('shows results overlay when marking notifications as read', async () => {
  const { promise } = deferred()
  server.use(
    rest.patch(
      'https://exercism.test/notifications/mark_as_read',
      (req, res, ctx) => {
        return promise.then(() => {
          res(ctx.status(200), ctx.json({}))
        })
      }
    )
  )

  render(
    <NotificationsList
      request={{ endpoint: 'https://exercism.test/notifications', options: {} }}
      links={{ markAsRead: 'https://exercism.test/notifications/mark_as_read' }}
    />
  )

  await waitForElementToBeRemoved(screen.getByRole('alert'))
  userEvent.click(await screen.findByRole('checkbox'))
  userEvent.click(await screen.findByRole('button', { name: /mark as read/i }))

  expect(screen.getByAltText(/loading data/i)).toBeInTheDocument()
})

test('disables mark as read button when fetching list', async () => {
  server.use(
    rest.get('https://exercism.test/notifications', (req, res, ctx) => {
      return res(
        ctx.status(200),
        ctx.json({
          results: [
            {
              uuid: 'notification',
              url: 'https://exercism.test/notifications/notification',
              text: 'A student has replied to your post',
              created_at: new Date().toISOString(),
              image_type: 'avatar',
              image_url: 'https://exercism.test/students/1/avatar.png',
            },
          ],
          meta: {
            currentPage: 1,
            totalCount: 1,
            totalPages: 2,
            links: {
              all: 'https://exercism.test/notifications',
            },
            unreadCount: 0,
          },
        })
      )
    })
  )
  render(
    <NotificationsList
      request={{ endpoint: 'https://exercism.test/notifications', options: {} }}
      links={{ markAsRead: 'https://exercism.test/notifications/mark_as_read' }}
    />
  )

  await waitForElementToBeRemoved(screen.getByRole('alert'))
  userEvent.click(await screen.findByRole('checkbox'))
  userEvent.click(await screen.findByRole('button', { name: /next/i }))

  expect(screen.getByRole('button', { name: /mark as read/i })).toBeDisabled()
})

test('disables checkboxes when fetching list', async () => {
  server.use(
    rest.get('https://exercism.test/notifications', (req, res, ctx) => {
      return res(
        ctx.status(200),
        ctx.json({
          results: [
            {
              uuid: 'notification',
              url: 'https://exercism.test/notifications/notification',
              text: 'A student has replied to your post',
              created_at: new Date().toISOString(),
              image_type: 'avatar',
              image_url: 'https://exercism.test/students/1/avatar.png',
            },
          ],
          meta: {
            currentPage: 1,
            totalCount: 1,
            totalPages: 2,
            links: {
              all: 'https://exercism.test/notifications',
            },
            unreadCount: 0,
          },
        })
      )
    })
  )
  render(
    <NotificationsList
      request={{ endpoint: 'https://exercism.test/notifications', options: {} }}
      links={{ markAsRead: 'https://exercism.test/notifications/mark_as_read' }}
    />
  )

  await waitForElementToBeRemoved(screen.getByRole('alert'))
  const checkbox = await screen.findByRole('checkbox')
  userEvent.click(await screen.findByRole('button', { name: /next/i }))

  expect(checkbox).toBeDisabled()
})

test('disables mark as read button when processing', async () => {
  const { promise } = deferred()
  server.use(
    rest.patch(
      'https://exercism.test/notifications/mark_as_read',
      (req, res, ctx) => {
        return promise.then(() => {
          res(ctx.status(200), ctx.json({}))
        })
      }
    )
  )

  render(
    <NotificationsList
      request={{ endpoint: 'https://exercism.test/notifications', options: {} }}
      links={{ markAsRead: 'https://exercism.test/notifications/mark_as_read' }}
    />
  )

  await waitForElementToBeRemoved(screen.getByRole('alert'))
  userEvent.click(await screen.findByRole('checkbox'))
  const markAsReadButton = await screen.findByRole('button', {
    name: /mark as read/i,
  })
  userEvent.click(markAsReadButton)

  await waitFor(() => {
    expect(markAsReadButton).toBeDisabled()
  })
})

test('disables checkboxes when processing', async () => {
  const { promise } = deferred()
  server.use(
    rest.patch(
      'https://exercism.test/notifications/mark_as_read',
      (req, res, ctx) => {
        return promise.then(() => {
          res(ctx.status(200), ctx.json({}))
        })
      }
    )
  )

  render(
    <NotificationsList
      request={{ endpoint: 'https://exercism.test/notifications', options: {} }}
      links={{ markAsRead: 'https://exercism.test/notifications/mark_as_read' }}
    />
  )

  await waitForElementToBeRemoved(screen.getByRole('alert'))
  const checkbox = await screen.findByRole('checkbox')
  userEvent.click(checkbox)
  userEvent.click(await screen.findByRole('button', { name: /mark as read/i }))

  await waitFor(() => {
    expect(checkbox).toBeDisabled()
  })
})

test('shows API error when marking notifications as read', async () => {
  await expectConsoleError(async () => {
    server.use(
      rest.patch(
        'https://exercism.test/notifications/mark_as_read',
        (req, res, ctx) => {
          return res(
            ctx.status(422),
            ctx.json({
              error: {
                message: 'notifications not found',
              },
            })
          )
        }
      )
    )

    render(
      <NotificationsList
        request={{
          endpoint: 'https://exercism.test/notifications',
          options: {},
        }}
        links={{
          markAsRead: 'https://exercism.test/notifications/mark_as_read',
        }}
      />
    )

    await waitForElementToBeRemoved(screen.getByRole('alert'))
    userEvent.click(await screen.findByRole('checkbox'))
    const markAsReadButton = await screen.findByRole('button', {
      name: /mark as read/i,
    })
    userEvent.click(markAsReadButton)

    expect(
      await screen.findByText('notifications not found')
    ).toBeInTheDocument()
  })
})

test('shows generic error when marking notifications as read', async () => {
  await expectConsoleError(async () => {
    render(
      <NotificationsList
        request={{
          endpoint: 'https://exercism.test/notifications',
          options: {},
        }}
        links={{ markAsRead: 'weirdendpoint' }}
      />
    )

    await waitForElementToBeRemoved(screen.getByRole('alert'))
    userEvent.click(await screen.findByRole('checkbox'))
    const markAsReadButton = await screen.findByRole('button', {
      name: /mark as read/i,
    })
    userEvent.click(markAsReadButton)

    expect(
      await screen.findByText('Unable to mark notifications as read')
    ).toBeInTheDocument()
  })
})
