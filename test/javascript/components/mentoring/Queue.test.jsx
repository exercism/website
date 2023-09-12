import React from 'react'
import { render, screen } from '@testing-library/react'
import { rest } from 'msw'
import { setupServer } from 'msw/node'
import '@testing-library/jest-dom/extend-expect'
import { default as Queue } from '@/components/mentoring/Queue'
import { TestQueryCache } from '../../support/TestQueryCache'
import { silenceConsole } from '../../support/silence-console'
import { queryClient } from '../../setupTests'

test('shows API errors when fetching queue', async () => {
  silenceConsole()

  const server = setupServer(
    rest.get('https://exercism.test/tracks', (req, res, ctx) => {
      return res(
        ctx.status(200),
        ctx.json({
          tracks: [
            {
              id: 'ruby',
              title: 'Ruby',
              links: {
                exercises: 'https://exercism.test/exercises/ruby',
              },
            },
          ],
        })
      )
    }),
    rest.get('https://exercism.test/exercises/ruby', (req, res, ctx) => {
      return res(ctx.status(200), ctx.json([]))
    }),
    rest.get('https://exercism.test/queue', (req, res, ctx) => {
      return res(
        ctx.status(422),
        ctx.json({
          error: {
            message: 'Unable to fetch queue',
          },
        })
      )
    })
  )
  server.listen()

  render(
    <TestQueryCache queryClient={queryClient}>
      <Queue
        queueRequest={{
          endpoint: 'https://exercism.test/queue',
          query: { trackSlug: 'ruby' },
        }}
        defaultTrack={{
          id: 'ruby',
          links: {
            exercises: 'https://exercism.test/tracks/ruby/exercises',
          },
        }}
        tracksRequest={{
          endpoint: 'https://exercism.test/tracks',
        }}
        links={{ tracks: 'https://exercism.test/tracks' }}
        sortOptions={[{ label: 'Sort by Newest First', value: 'newest_first' }]}
      />
    </TestQueryCache>
  )

  expect(await screen.findByText('Unable to fetch queue')).toBeInTheDocument()

  server.close()
})

test('shows generic errors when fetching queue', async () => {
  silenceConsole()

  const server = setupServer(
    rest.get('https://exercism.test/tracks', (req, res, ctx) => {
      return res(
        ctx.status(200),
        ctx.json({
          tracks: [
            {
              id: 'ruby',
              title: 'Ruby',
              links: {
                exercises: 'https://exercism.test/exercises/ruby',
              },
            },
          ],
        })
      )
    }),
    rest.get('https://exercism.test/exercises/ruby', (req, res, ctx) => {
      return res(ctx.status(200), ctx.json([]))
    })
  )
  server.listen()

  render(
    <TestQueryCache queryClient={queryClient}>
      <Queue
        queueRequest={{
          endpoint: 'wrongendpoint',
          query: { trackSlug: 'ruby' },
        }}
        defaultTrack={{
          id: 'ruby',
          links: {
            exercises: 'https://exercism.test/tracks/ruby/exercises',
          },
        }}
        tracksRequest={{
          endpoint: 'https://exercism.test/tracks',
        }}
        links={{ tracks: 'https://exercism.test/tracks' }}
        sortOptions={[{ label: 'Sort by Newest First', value: 'newest_first' }]}
      />
    </TestQueryCache>
  )

  expect(await screen.findByText('Unable to fetch queue')).toBeInTheDocument()

  server.close()
})

test('shows API errors when fetching tracks', async () => {
  silenceConsole()
  const server = setupServer(
    rest.get('https://exercism.test/tracks', (req, res, ctx) => {
      return res(
        ctx.status(422),
        ctx.json({
          error: {
            message: 'Unable to get track',
          },
        })
      )
    }),
    rest.get('https://exercism.test/queue', (req, res, ctx) => {
      return res(
        ctx.status(200),
        ctx.json({
          results: [],
          meta: {},
        })
      )
    })
  )
  server.listen()

  render(
    <TestQueryCache queryClient={queryClient}>
      <Queue
        queueRequest={{
          endpoint: 'https://exercism.test/queue',
          query: { trackSlug: 'ruby' },
        }}
        defaultTrack={{
          id: 'ruby',
          links: {
            exercises: 'https://exercism.test/tracks/ruby/exercises',
          },
        }}
        tracksRequest={{
          endpoint: 'https://exercism.test/tracks',
        }}
        links={{ tracks: 'https://exercism.test/tracks' }}
        sortOptions={[{ label: 'Sort by Newest First', value: 'newest_first' }]}
      />
    </TestQueryCache>
  )

  expect(await screen.findByText('Unable to get track')).toBeInTheDocument()

  server.close()
})

test('shows generic errors when fetching tracks', async () => {
  silenceConsole()
  const server = setupServer(
    rest.get('https://exercism.test/queue', (req, res, ctx) => {
      return res(
        ctx.status(200),
        ctx.json({
          results: [],
          meta: {},
        })
      )
    })
  )
  server.listen()

  render(
    <TestQueryCache queryClient={queryClient}>
      <Queue
        queueRequest={{
          endpoint: 'https://exercism.test/queue',
          query: { trackSlug: 'ruby' },
        }}
        defaultTrack={{
          id: 'ruby',
          links: {
            exercises: 'https://exercism.test/tracks/ruby/exercises',
          },
        }}
        tracksRequest={{
          endpoint: 'weirdendpoitn',
        }}
        links={{ tracks: 'https://exercism.test/tracks' }}
        sortOptions={[{ label: 'Sort by Newest First', value: 'newest_first' }]}
      />
    </TestQueryCache>
  )

  expect(await screen.findByText('Unable to fetch tracks')).toBeInTheDocument()

  server.close()
})

test('shows API errors when fetching tracks 2', async () => {
  silenceConsole()
  const server = setupServer(
    rest.get('https://exercism.test/tracks', (req, res, ctx) => {
      return res(
        ctx.status(422),
        ctx.json({
          error: {
            message: 'Unable to get track',
          },
        })
      )
    }),
    rest.get('https://exercism.test/queue', (req, res, ctx) => {
      return res(
        ctx.status(200),
        ctx.json({
          results: [],
          meta: {},
        })
      )
    })
  )
  server.listen()

  render(
    <TestQueryCache queryClient={queryClient}>
      <Queue
        queueRequest={{
          endpoint: 'https://exercism.test/queue',
          query: { trackSlug: 'ruby' },
        }}
        defaultTrack={{
          id: 'ruby',
          links: {
            exercises: 'https://exercism.test/tracks/ruby/exercises',
          },
        }}
        tracksRequest={{
          endpoint: 'https://exercism.test/tracks',
        }}
        links={{ tracks: 'https://exercism.test/tracks' }}
        sortOptions={[{ label: 'Sort by Newest First', value: 'newest_first' }]}
      />
    </TestQueryCache>
  )

  expect(await screen.findByText('Unable to get track')).toBeInTheDocument()

  server.close()
})

test('shows API errors when fetching exercises', async () => {
  silenceConsole()

  const track = {
    id: 'ruby',
    title: 'Ruby',
    links: {
      exercises: 'https://exercism.test/exercises/ruby',
    },
  }
  const server = setupServer(
    rest.get('https://exercism.test/tracks', (req, res, ctx) => {
      return res(
        ctx.status(200),
        ctx.json({
          tracks: [track],
        })
      )
    }),
    rest.get('https://exercism.test/exercises/ruby', (req, res, ctx) => {
      return res(
        ctx.status(422),
        ctx.json({
          error: {
            message: 'Unable to get exercises',
          },
        })
      )
    })
  )
  server.listen()

  render(
    <TestQueryCache queryClient={queryClient}>
      <Queue
        queueRequest={{
          endpoint: 'https://exercism.test/queue',
          query: { trackSlug: 'ruby' },
        }}
        tracksRequest={{
          endpoint: 'https://exercism.test/tracks',
        }}
        defaultTrack={track}
        links={{ tracks: 'https://exercism.test/tracks' }}
        sortOptions={[{ label: 'Sort by Newest First', value: 'newest_first' }]}
      />
    </TestQueryCache>
  )

  expect(await screen.findByText('Unable to get exercises')).toBeInTheDocument()

  server.close()
})

test('shows generic errors when fetching exercises', async () => {
  silenceConsole()

  const track = {
    id: 'ruby',
    title: 'Ruby',
    links: {
      exercises: 'weirdendpoint',
    },
  }
  const server = setupServer(
    rest.get('https://exercism.test/tracks', (req, res, ctx) => {
      return res(
        ctx.status(200),
        ctx.json({
          tracks: [track],
        })
      )
    })
  )
  server.listen()

  render(
    <TestQueryCache queryClient={queryClient}>
      <Queue
        queueRequest={{
          endpoint: 'https://exercism.test/queue',
          query: { trackSlug: 'ruby' },
        }}
        tracksRequest={{
          endpoint: 'https://exercism.test/tracks',
        }}
        defaultTrack={track}
        links={{ tracks: 'https://exercism.test/tracks' }}
        sortOptions={[{ label: 'Sort by Newest First', value: 'newest_first' }]}
      />
    </TestQueryCache>
  )

  expect(
    await screen.findByText('Unable to fetch exercises')
  ).toBeInTheDocument()

  server.close()
})
