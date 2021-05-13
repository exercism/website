import React from 'react'
import { render, screen } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { ExerciseCompletedModal } from '../../../../../app/javascript/components/modals/complete-exercise-modal/ExerciseCompletedModal'

test('shows information', async () => {
  const completion = {
    exercise: {
      title: 'Lasagna',
      links: { self: 'https://exercism.test/exercise' },
    },
    conceptProgressions: [
      {
        name: 'Arrays',
        from: 4,
        to: 5,
        total: 5,
      },
    ],
    unlockedConcepts: [
      {
        name: 'Strings',
      },
    ],
    unlockedExercises: [
      {
        iconName: 'bob',
        title: 'Bob',
      },
    ],
  }

  render(
    <ExerciseCompletedModal
      open={true}
      completion={completion}
      ariaHideApp={false}
    />
  )

  expect(screen.getByRole('banner')).toHaveTextContent(
    "You've completedLasagna!"
  )
  expect(screen.getByText('Ar')).toBeInTheDocument()
  expect(screen.getByText('Arrays')).toBeInTheDocument()
  expect(
    screen.getByRole('heading', { name: "You've unlocked 1 exercise" })
  ).toBeInTheDocument()
  expect(screen.getByText('Bob')).toBeInTheDocument()
  expect(
    screen.getByRole('heading', { name: "You've unlocked 1 concept" })
  ).toBeInTheDocument()
  expect(screen.getByText('St')).toBeInTheDocument()
  expect(screen.getByText('Strings')).toBeInTheDocument()
})

test('hides unlocks section when there are no unlocked exercises and concepts', async () => {
  const completion = {
    exercise: {
      title: 'Lasagna',
      links: { self: 'https://exercism.test/exercise' },
    },
    conceptProgressions: [
      {
        name: 'Arrays',
        from: 4,
        to: 5,
        total: 5,
      },
    ],
    unlockedConcepts: [],
    unlockedExercises: [],
  }

  render(
    <ExerciseCompletedModal
      open={true}
      completion={completion}
      ariaHideApp={false}
    />
  )

  expect(screen.queryByTestId('unlocks')).not.toBeInTheDocument()
})

test('hides unlocked exercises section when there are no unlocked exercises', async () => {
  const completion = {
    exercise: {
      title: 'Lasagna',
      links: { self: 'https://exercism.test/exercise' },
    },
    conceptProgressions: [
      {
        name: 'Arrays',
        from: 4,
        to: 5,
        total: 5,
      },
    ],
    unlockedConcepts: [
      {
        name: 'Strings',
      },
    ],
    unlockedExercises: [],
  }

  render(
    <ExerciseCompletedModal
      open={true}
      completion={completion}
      ariaHideApp={false}
    />
  )

  expect(
    screen.queryByRole('heading', { name: "You've unlocked 0 exercises" })
  ).not.toBeInTheDocument()
})

test('hides unlocked concepts section when there are no unlocked concepts', async () => {
  const completion = {
    exercise: {
      title: 'Lasagna',
      links: { self: 'https://exercism.test/exercise' },
    },
    conceptProgressions: [
      {
        name: 'Arrays',
        from: 4,
        to: 5,
        total: 5,
      },
    ],
    unlockedConcepts: [],
    unlockedExercises: [],
  }

  render(
    <ExerciseCompletedModal
      open={true}
      completion={completion}
      ariaHideApp={false}
    />
  )

  expect(
    screen.queryByRole('heading', { name: "You've unlocked 0 concepts" })
  ).not.toBeInTheDocument()
})
