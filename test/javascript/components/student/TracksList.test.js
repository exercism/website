import React from 'react'
import { render, fireEvent, screen, waitFor } from '@testing-library/react'
import { rest } from 'msw'
import { setupServer } from 'msw/node'
import '@testing-library/jest-dom/extend-expect'
import { awaitPopper } from '../../support/await-popper'
import { TracksList } from '../../../../app/javascript/components/student/TracksList'

test('shows stale data while fetching', async () => {
  const server = setupServer(
    rest.get('https://exercism.test/tracks', (req, res, ctx) => {
      return res(ctx.status(200), ctx.json({ tracks: [] }))
    })
  )
  server.listen()
  const statusOptions = [{ label: 'All', value: 'all' }]
  render(
    <TracksList
      request={{
        endpoint: 'https://exercism.test/tracks',
        query: {},
        options: {
          initialData: { tracks: [{ id: 2, title: 'Ruby', tags: [] }] },
        },
      }}
      tagOptions={[]}
      statusOptions={statusOptions}
    />
  )
  await awaitPopper()

  fireEvent.change(screen.getByPlaceholderText('Search language tracks'), {
    target: { value: 'Go' },
  })

  expect(screen.getByText('Ruby')).toBeInTheDocument()

  server.close()
})

test('hides reset filter button when no filters are selected', async () => {
  const server = setupServer(
    rest.get('https://exercism.test/tracks', (req, res, ctx) => {
      return res(ctx.status(200), ctx.json({ tracks: [] }))
    })
  )
  server.listen()
  const statusOptions = [{ label: 'All', value: 'all' }]

  render(
    <TracksList
      request={{
        endpoint: 'https://exercism.test/tracks',
        query: {},
        options: {
          initialData: { tracks: [{ id: 2, title: 'Ruby', tags: [] }] },
        },
      }}
      tagOptions={[]}
      statusOptions={statusOptions}
    />
  )

  expect(
    screen.queryByRole('button', { name: 'Reset filters' })
  ).not.toBeInTheDocument()

  server.close()
})
