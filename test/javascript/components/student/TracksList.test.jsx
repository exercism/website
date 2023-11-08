import React from 'react'
import {
  screen,
  waitFor,
  waitForElementToBeRemoved,
} from '@testing-library/react'
import { render } from '../../test-utils'
import { rest } from 'msw'
import { setupServer } from 'msw/node'
import '@testing-library/jest-dom/extend-expect'
import TracksList from '../../../../app/javascript/components/student/TracksList'
import userEvent from '@testing-library/user-event'

const ALL_TRACKS = [{ slug: 'ruby', title: 'Ruby', tags: [] }]

const server = setupServer(
  rest.get('https://exercism.test/tracks', (req, res, ctx) => {
    return res(
      ctx.status(200),
      ctx.json({
        tracks: ALL_TRACKS.filter((t) => t.title === req.body.criteria),
      })
    )
  })
)

beforeAll(() => server.listen())
afterAll(() => server.close())

test('shows stale data while fetching', async () => {
  const statusOptions = [{ label: 'All', value: 'all' }]
  render(
    <TracksList
      request={{
        endpoint: 'https://exercism.test/tracks',
        query: {},
        options: { initialData: { tracks: ALL_TRACKS } },
      }}
      tagOptions={[]}
      statusOptions={statusOptions}
    />
  )

  userEvent.type(screen.getByPlaceholderText('Search language tracks'), 'Go')

  expect(screen.getByText('Ruby')).toBeInTheDocument()

  await waitForElementToBeRemoved(() => screen.getByText('Ruby'))
})

test('hides reset filter button when no filters are selected', async () => {
  const statusOptions = [{ label: 'All', value: 'all' }]

  render(
    <TracksList
      request={{
        endpoint: 'https://exercism.test/tracks',
        query: {},
        options: { initialData: { tracks: ALL_TRACKS } },
      }}
      tagOptions={[]}
      statusOptions={statusOptions}
    />
  )

  expect(
    screen.queryByRole('button', { name: 'Reset filters' })
  ).not.toBeInTheDocument()
})

test('shows empty state and allows resetting', async () => {
  const statusOptions = [{ label: 'All', value: 'all' }]

  render(
    <TracksList
      request={{
        endpoint: 'https://exercism.test/tracks',
        query: { tags: [] },
        options: { initialData: { tracks: ALL_TRACKS } },
      }}
      tagOptions={[
        {
          category: 'Platform',
          options: [{ value: 'windows', label: 'Windows' }],
        },
      ]}
      statusOptions={statusOptions}
    />
  )
  userEvent.type(screen.getByPlaceholderText('Search language tracks'), 'Go')
  userEvent.click(screen.getByRole('button', { name: /filter/i }))
  userEvent.click(await screen.findByLabelText('Windows'))
  userEvent.click(screen.getByRole('button', { name: /apply/i }))

  const noResultsFound = await screen.findByText('No results found')
  expect(noResultsFound).toBeInTheDocument()

  userEvent.click(
    screen.getByRole('button', { name: /reset search and filters/i })
  )

  await waitFor(() =>
    expect(screen.getByPlaceholderText('Search language tracks')).toHaveValue(
      ''
    )
  )
  userEvent.click(screen.getByRole('button', { name: /filter by/i }))
  expect(screen.getByRole('checkbox', { name: 'Windows' })).not.toBeChecked()
})
