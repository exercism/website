import React from 'react'
import { render } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { Track } from '../../../../../app/javascript/components/student/tracks-list/Track'

test('hides progress bar if track is unjoined', () => {
  const { queryByTestId } = render(
    <Track track={{ isJoined: false, isNew: false, tags: [] }} />
  )

  expect(queryByTestId('track-progress-bar')).not.toBeInTheDocument()
})

test('hides joined status if track is unjoined', () => {
  const { queryByText } = render(
    <Track track={{ isJoined: false, isNew: false, tags: [] }} />
  )

  expect(queryByText('Joined')).not.toBeInTheDocument()
})

test('shows completed concept exercises if track is joined', () => {
  const { queryByText } = render(
    <Track
      track={{
        isJoined: false,
        isNew: false,
        tags: [],
        numConceptExercises: 2,
        numCompletedConceptExercises: 1,
      }}
    />
  )

  expect(queryByText('1/2 concepts')).toBeInTheDocument()
})

test('shows number of concept exercises if track is unjoined', () => {
  const { queryByText } = render(
    <Track
      track={{
        isJoined: false,
        isNew: false,
        tags: [],
        numConceptExercises: 2,
      }}
    />
  )

  expect(queryByText('2 concepts')).toBeInTheDocument()
})

test('shows completed practice exercises if track is joined', () => {
  const { queryByText } = render(
    <Track
      track={{
        isJoined: false,
        isNew: false,
        tags: [],
        numPracticeExercises: 5,
        numCompletedPracticeExercises: 3,
      }}
    />
  )

  expect(queryByText('3/5 exercises')).toBeInTheDocument()
})

test('shows number of practice exercises if track is unjoined', () => {
  const { queryByText } = render(
    <Track
      track={{
        isJoined: false,
        isNew: false,
        tags: [],
        numPracticeExercises: 5,
      }}
    />
  )

  expect(queryByText('5 exercises')).toBeInTheDocument()
})
