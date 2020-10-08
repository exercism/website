import React from 'react'
import { render, fireEvent } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { Header } from '../../../../../app/javascript/components/student/tracks-list/Header'

test('pluralizes tracks when filtered', () => {
  const { queryByText } = render(
    <Header
      latestData={{ tracks: ['ruby', 'go'] }}
      query={{ criteria: 'test' }}
    />
  )

  expect(queryByText('Showing 2 tracks')).toBeInTheDocument()
})

test('shows message when criteria is passed in', () => {
  const { queryByText } = render(
    <Header latestData={{ tracks: ['ruby'] }} query={{ criteria: 'test' }} />
  )

  expect(queryByText('Showing 1 track')).toBeInTheDocument()
})

test('shows message when tags are passed in', () => {
  const { queryByText } = render(
    <Header latestData={{ tracks: ['ruby'] }} query={{ tags: ['oop'] }} />
  )

  expect(queryByText('Showing 1 track')).toBeInTheDocument()
})

test('shows default message for no query', () => {
  const { queryByText } = render(<Header latestData={{ tracks: ['ruby'] }} />)

  expect(queryByText("Exercism's Language Tracks")).toBeInTheDocument()
})

test('shows loading spinner', () => {
  const { queryByText } = render(<Header latestData={undefined} />)

  expect(queryByText('Loading')).toBeInTheDocument()
})
