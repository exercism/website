import React from 'react'
import { render, fireEvent, waitFor } from '@testing-library/react'
import { rest } from 'msw'
import { setupServer } from 'msw/node'
import '@testing-library/jest-dom/extend-expect'
import { TracksList } from '../../../../app/javascript/components/student/TracksList'

test('shows stale data while fetching', async () => {
  const server = setupServer(
    rest.get('https://exercism.test/tracks', (req, res, ctx) => {
      return res(ctx.status(200), ctx.json({ tracks: [] }))
    })
  )
  server.listen()
  const statusOptions = [{ label: 'All', value: 'all' }]
  const { getByText, getByPlaceholderText } = render(
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

  fireEvent.change(getByPlaceholderText('Search language tracks'), {
    target: { value: 'Go' },
  })

  expect(getByText('Ruby')).toBeInTheDocument()

  server.close()
})
