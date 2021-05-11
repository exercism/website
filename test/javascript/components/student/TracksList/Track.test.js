import React from 'react'
import { render, screen } from '@testing-library/react'
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
        numConcepts: 2,
        numCompletedConcepts: 1,
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
        numConcepts: 2,
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
        numExercises: 5,
        numCompletedExercises: 3,
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
        numExercises: 5,
      }}
    />
  )

  expect(queryByText('5 exercises')).toBeInTheDocument()
})

test('shows new tag if track is new', () => {
  render(
    <Track
      track={{
        isJoined: false,
        isNew: true,
        tags: [],
        numExercises: 5,
      }}
    />
  )

  expect(screen.getByText('New')).toBeInTheDocument()
})

test('hides new tag if track is not new', () => {
  render(
    <Track
      track={{
        isJoined: false,
        isNew: false,
        tags: [],
        numExercises: 5,
      }}
    />
  )

  expect(screen.queryByText('New')).not.toBeInTheDocument()
})

test('shows v3 tag if track has more than 5 concepts', () => {
  render(
    <Track
      track={{
        isJoined: false,
        isNew: true,
        tags: [],
        numConcepts: 6,
      }}
    />
  )

  expect(screen.getByText('Concepts')).toBeInTheDocument()
})

test('hides v3 tag if track has less than 5 concepts', () => {
  render(
    <Track
      track={{
        isJoined: false,
        isNew: true,
        tags: [],
        numConcepts: 5,
      }}
    />
  )

  expect(screen.queryByText('V3')).not.toBeInTheDocument()
})
