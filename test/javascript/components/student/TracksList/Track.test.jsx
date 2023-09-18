import React from 'react'
import { render, screen } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { Track } from '../../../../../app/javascript/components/student/tracks-list/Track'

test('hides progress bar if track is unjoined', () => {
  render(<Track track={{ isJoined: false, isNew: false, tags: [] }} />)

  expect(screen.queryByTestId('track-progress-bar')).not.toBeInTheDocument()
})

test('hides joined status if track is unjoined', () => {
  render(<Track track={{ isJoined: false, isNew: false, tags: [] }} />)

  expect(screen.queryByText('Joined')).not.toBeInTheDocument()
})

test('shows completed concept exercises if track is joined', () => {
  render(
    <Track
      track={{
        course: true,
        isJoined: false,
        isNew: false,
        tags: [],
        numConcepts: 2,
        numCompletedConcepts: 1,
      }}
    />
  )

  expect(screen.queryByText('1/2 concepts')).toBeInTheDocument()
})

test('shows number of concept exercises if track is unjoined', () => {
  render(
    <Track
      track={{
        course: true,
        isJoined: false,
        isNew: false,
        tags: [],
        numConcepts: 2,
      }}
    />
  )

  expect(screen.queryByText('2 concepts')).toBeInTheDocument()
})

test('shows completed practice exercises if track is joined', () => {
  render(
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

  expect(screen.queryByText('3/5 exercises')).toBeInTheDocument()
})

test('shows number of practice exercises if track is unjoined', () => {
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

  expect(screen.queryByText('5 exercises')).toBeInTheDocument()
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

test('hides new tag if track is joined', () => {
  render(
    <Track
      track={{
        isJoined: true,
        isNew: true,
        tags: [],
        numExercises: 5,
      }}
    />
  )

  expect(screen.queryByText('New')).not.toBeInTheDocument()
})

test('shows learning mode tag if course mode is enabled', () => {
  render(
    <Track
      track={{
        course: true,
        isJoined: false,
        isNew: true,
        tags: [],
        numConcepts: 6,
      }}
    />
  )

  expect(screen.getByText('Learning Mode')).toBeInTheDocument()
  expect(screen.getByText('6 concepts')).toBeInTheDocument()
})

test('hides learning mode tag if course mode is disabled', () => {
  render(
    <Track
      track={{
        course: false,
        isJoined: false,
        isNew: true,
        tags: [],
        numConcepts: 5,
      }}
    />
  )

  expect(screen.queryByText('Learning Mode')).not.toBeInTheDocument()
})

test('hides learning mode tag if track is joined', () => {
  render(
    <Track
      track={{
        isJoined: true,
        isNew: true,
        tags: [],
        numConcepts: 7,
      }}
    />
  )

  expect(screen.queryByText('Learning Mode')).not.toBeInTheDocument()
})
