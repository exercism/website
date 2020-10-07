import React from 'react'
import { render, fireEvent } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { TracksList } from '../../../../app/javascript/components/student/TracksList'

test('disables the selected status filter', () => {
  const options = [
    { label: 'All', value: 'all' },
    { label: 'Joined', value: 'joined' },
    { label: 'Unjoined', value: 'unjoined' },
  ]
  const { getByText } = render(
    <TracksList
      statusOptions={options}
      request={{ query: { status: 'all' } }}
    />
  )

  expect(getByText('All')).toBeDisabled()
})
