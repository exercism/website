import React from 'react'
import { render, screen } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { ExerciseWidget } from '../../../../app/javascript/components/common/ExerciseWidget'
import {
  Exercise,
  SolutionForStudent,
  Track,
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
    isRecommended: false,
    links: {
      self: 'https://exercism.test/exercise',
    },
  }
  const track: Track = {
    id: '1',
    title: 'Ruby',
    iconUrl: 'https://exercism.test/icon',
  }

  render(<ExerciseWidget exercise={exercise} size="medium" track={track} />)

  expect(screen.getByRole('link')).toHaveAttribute(
    'href',
    'https://exercism.test/exercise'
  )
  expect(
    screen.getByRole('img', {
      name: "Icon for exercise called Lucian's Luscious Lasagna",
    })
  ).toHaveAttribute('src', 'https://exercism.test/icon')
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
    isRecommended: false,
  }
  const track: Track = {
    id: '1',
    title: 'Ruby',
    iconUrl: 'https://exercism.test/icon',
  }

  render(<ExerciseWidget exercise={exercise} size="medium" track={track} />)

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
    isRecommended: true,
    links: {
      self: 'https://exercism.test/exercise',
    },
  }
  const solution: SolutionForStudent = {
    url: 'https://exercism.test/solution',
    status: 'completed',
    hasNotifications: true,
    exercise: {
      slug: 'ruby',
    },
    numComments: 2,
    numIterations: 3,
  }
  const track: Track = {
    id: '1',
    title: 'Ruby',
    iconUrl: 'https://exercism.test/icon',
  }

  render(
    <ExerciseWidget
      exercise={exercise}
      size="medium"
      track={track}
      solution={solution}
    />
  )

  expect(screen.getByRole('link')).toHaveAttribute(
    'href',
    'https://exercism.test/solution'
  )
  expect(
    screen.getByRole('img', {
      name: "Icon for exercise called Lucian's Luscious Lasagna",
    })
  ).toHaveAttribute('src', 'https://exercism.test/icon')
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
    isRecommended: true,
    links: {
      self: 'https://exercism.test/exercise',
    },
  }
  const track: Track = {
    id: '1',
    title: 'Ruby',
    iconUrl: 'https://exercism.test/icon',
  }

  render(<ExerciseWidget exercise={exercise} size="small" track={track} />)

  expect(screen.getByRole('link')).toHaveAttribute(
    'class',
    'c-exercise-widget --available --small'
  )
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
    isRecommended: true,
    links: {
      self: 'https://exercism.test/exercise',
    },
  }
  const track: Track = {
    id: '1',
    title: 'Ruby',
    iconUrl: 'https://exercism.test/icon',
  }

  render(<ExerciseWidget exercise={exercise} size="medium" track={track} />)

  expect(
    screen.queryByRole('img', { name: 'Exercise is completed' })
  ).not.toBeInTheDocument()
})
