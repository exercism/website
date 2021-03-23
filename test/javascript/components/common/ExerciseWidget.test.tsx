import React from 'react'
import { render, screen } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { ExerciseWidget } from '../../../../app/javascript/components/common/ExerciseWidget'
import {
  Exercise,
  SolutionForStudent,
} from '../../../../app/javascript/components/types'

test('renders an available exercise', async () => {
  const exercise: Exercise = {
    slug: 'lasagna',
    title: "Lucian's Luscious Lasagna",
    iconUrl: 'https://exercism.test/icon',
    blurb: 'Tasty exercise',
    difficulty: 'easy',
    isAvailable: true,
    isCompleted: false,
    links: {
      self: 'https://exercism.test/exercise',
    },
  }

  render(<ExerciseWidget exercise={exercise} size="medium" />)

  expect(screen.getByRole('link')).toHaveAttribute(
    'href',
    'https://exercism.test/exercise'
  )
  expect(screen.getByRole('img')).toHaveAttribute(
    'src',
    'https://exercism.test/icon'
  )
  expect(screen.getByText("Lucian's Luscious Lasagna")).toBeInTheDocument()
  expect(screen.getByText('Available')).toBeInTheDocument()
  expect(screen.queryByText('Locked')).not.toBeInTheDocument()
  expect(screen.getByText('Easy')).toBeInTheDocument()
  expect(screen.getByText('Tasty exercise')).toBeInTheDocument()
})

test('renders a locked exercise', async () => {
  const exercise: Exercise = {
    slug: 'lasagna',
    title: "Lucian's Luscious Lasagna",
    iconUrl: 'https://exercism.test/icon',
    blurb: 'Tasty exercise',
    difficulty: 'easy',
    isAvailable: false,
    isCompleted: false,
  }

  render(<ExerciseWidget exercise={exercise} size="medium" />)

  expect(screen.getByText('Locked')).toBeInTheDocument()
  expect(screen.queryByText('Available')).not.toBeInTheDocument()
  expect(screen.queryByRole('link')).not.toBeInTheDocument()
})

test('renders a solution when passed in', async () => {
  const exercise: Exercise = {
    slug: 'lasagna',
    title: "Lucian's Luscious Lasagna",
    iconUrl: 'https://exercism.test/icon',
    blurb: 'Tasty exercise',
    difficulty: 'easy',
    isAvailable: true,
    isCompleted: true,
    links: {
      self: 'https://exercism.test/exercise',
    },
  }
  const solution: SolutionForStudent = {
    url: 'https://exercism.test/solution',
    status: 'completed',
    numComments: 2,
    numIterations: 3,
  }

  render(
    <ExerciseWidget exercise={exercise} solution={solution} size="medium" />
  )

  expect(screen.getByRole('link')).toHaveAttribute(
    'href',
    'https://exercism.test/solution'
  )
  expect(screen.getByRole('img')).toHaveAttribute(
    'src',
    'https://exercism.test/icon'
  )
  expect(screen.getByText("Lucian's Luscious Lasagna")).toBeInTheDocument()
  expect(screen.getByText('Completed')).toBeInTheDocument()
  expect(screen.getByText('2')).toBeInTheDocument()
  expect(screen.getByText('3 iterations')).toBeInTheDocument()
})

test('renders a small version', async () => {
  const exercise: Exercise = {
    slug: 'lasagna',
    title: "Lucian's Luscious Lasagna",
    iconUrl: 'https://exercism.test/icon',
    blurb: 'Tasty exercise',
    difficulty: 'easy',
    isAvailable: true,
    isCompleted: true,
    links: {
      self: 'https://exercism.test/exercise',
    },
  }

  render(<ExerciseWidget exercise={exercise} size="small" />)

  expect(screen.getByRole('link')).toHaveAttribute(
    'class',
    'c-exercise-widget --small'
  )
  expect(screen.queryByText('Tasty exercise')).not.toBeInTheDocument()
  expect(screen.queryByRole('presentation')).not.toBeInTheDocument()
})

test('hides blurb if showDesc is false', async () => {
  const exercise: Exercise = {
    slug: 'lasagna',
    title: "Lucian's Luscious Lasagna",
    iconUrl: 'https://exercism.test/icon',
    blurb: 'Tasty exercise',
    difficulty: 'easy',
    isCompleted: true,
    isAvailable: true,
    links: {
      self: 'https://exercism.test/exercise',
    },
  }

  render(<ExerciseWidget exercise={exercise} size="medium" showDesc={false} />)

  expect(screen.queryByText('Tasty exercise')).not.toBeInTheDocument()
})

test('shows icon if exercise is completed', async () => {
  const exercise: Exercise = {
    slug: 'lasagna',
    title: "Lucian's Luscious Lasagna",
    iconUrl: 'https://exercism.test/icon',
    blurb: 'Tasty exercise',
    difficulty: 'easy',
    isAvailable: true,
    isCompleted: true,
    links: {
      self: 'https://exercism.test/exercise',
    },
  }

  render(<ExerciseWidget exercise={exercise} size="medium" />)

  expect(
    screen.getByRole('img', { name: 'Exercise is completed' })
  ).toBeInTheDocument()
})

test('hides icon if exercise is not completed', async () => {
  const exercise: Exercise = {
    slug: 'lasagna',
    title: "Lucian's Luscious Lasagna",
    iconUrl: 'https://exercism.test/icon',
    blurb: 'Tasty exercise',
    difficulty: 'easy',
    isAvailable: true,
    isCompleted: false,
    links: {
      self: 'https://exercism.test/exercise',
    },
  }

  render(<ExerciseWidget exercise={exercise} size="medium" />)

  expect(
    screen.queryByRole('img', { name: 'Exercise is completed' })
  ).not.toBeInTheDocument()
})
