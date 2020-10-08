import React from 'react'
import { render, fireEvent, waitFor } from '@testing-library/react'
import { rest } from 'msw'
import { setupServer } from 'msw/node'
import '@testing-library/jest-dom/extend-expect'
import { TracksList } from '../../../../app/javascript/components/student/TracksList'

test('disables the selected status filter', () => {
  const statusOptions = [
    { label: 'All', value: 'all' },
    { label: 'Joined', value: 'joined' },
    { label: 'Unjoined', value: 'unjoined' },
  ]
  const tagOptions = [
    {
      category: 'Style',
      options: [
        {
          value: 'oop',
          label: 'OOP',
        },
      ],
    },
  ]
  const { getByText } = render(
    <TracksList
      statusOptions={statusOptions}
      tagOptions={[]}
      request={{ query: { status: 'all' } }}
    />
  )

  expect(getByText('All')).toBeDisabled()
})

test('shows stale data while fetching', async () => {
  const server = setupServer(
    rest.get('https://exercism.test/tracks', (req, res, ctx) => {
      return res(ctx.delay())
    })
  )
  server.listen()
  const statusOptions = [{ label: 'All', value: 'all' }]
  const { getByText, getByPlaceholderText } = render(
    <TracksList
      request={{
        endpoint: 'https://exercism.test/tracks',
        query: {},
        options: { initialData: { tracks: [{ title: 'Ruby', tags: [] }] } },
      }}
      tagOptions={[]}
      statusOptions={statusOptions}
    />
  )

  fireEvent.change(getByPlaceholderText('Search language tracks'), {
    target: { value: 'Go' },
  })

  await waitFor(() => expect(getByText('Loading')).toBeInTheDocument())
  expect(getByText("Exercism's Language Tracks")).toBeInTheDocument()
  expect(getByText('Ruby')).toBeInTheDocument()

  server.close()
})
