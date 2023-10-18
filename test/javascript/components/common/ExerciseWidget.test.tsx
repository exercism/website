import React from 'react'
import { render, screen } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { ExerciseWidget } from '../../../../app/javascript/components/common/ExerciseWidget'
import {
  Exercise,
  SolutionForStudent,
  Track,
} from '../../../../app/javascript/components/types'

const track: Track = {
  slug: 'ruby',
  title: 'Ruby',
  iconUrl: 'https://exercism.test/track_icon',
  course: false,
  numConcepts: 0,
  numExercises: 0,
  numSolutions: 0,
  links: {
    self: '',
    exercises: '',
    concepts: '',
  },
}

const exercise: Exercise = {
  slug: 'lasagna',
  type: 'practice',
  title: "Lucian's Luscious Lasagna",
  iconUrl: 'https://exercism.test/exercise_icon',
  blurb: 'Tasty exercise',
  difficulty: 'easy',
  isExternal: false,
  isUnlocked: true,
  isRecommended: true,
  links: {
    self: 'https://exercism.test/exercise',
  },
}

const solution: SolutionForStudent = {
  privateUrl: 'https://exercism.test/solution',
  status: 'completed',
  mentoringStatus: 'requested',
  hasNotifications: true,
  exercise: {
    slug: 'ruby',
    iconUrl: '',
    title: 'Ruby',
  },
  isOutOfDate: true,
  numIterations: 3,
  uuid: '',
  publicUrl: '',
  updatedAt: '',
  track: {
    slug: '',
    title: '',
    iconUrl: '',
  },
}

test('renders a solution when passed in', async () => {
  render(
    <ExerciseWidget exercise={exercise} track={track} solution={solution} />
  )

  expect(screen.getByRole('link')).toHaveAttribute(
    'href',
    'https://exercism.test/solution'
  )
  expect(screen.getByRole('link')).toHaveAttribute(
    'class',
    'c-exercise-widget --completed --recommended --interactive'
  )
  expect(
    screen.getByRole('img', {
      name: "Icon for exercise called Lucian's Luscious Lasagna",
    })
  ).toHaveAttribute('src', 'https://exercism.test/exercise_icon')
  expect(screen.getByText("Lucian's Luscious Lasagna")).toBeInTheDocument()
  expect(
    screen.getByRole('img', {
      name: 'icon for Ruby track',
    })
  ).toHaveAttribute('src', 'https://exercism.test/track_icon')
  expect(screen.getByText('Ruby')).toBeInTheDocument()
  expect(screen.getByText('has notifications')).toBeInTheDocument()
  expect(screen.getByText('Completed')).toBeInTheDocument()
  expect(screen.getByAltText('Mentoring requested')).toBeInTheDocument()
  expect(screen.getByText('3 iterations')).toBeInTheDocument()
  expect(screen.getByText('Tasty exercise')).toBeInTheDocument()
  expect(
    screen.getByAltText(
      /This solution was solved against an older version of this exercise/i
    )
  ).toBeInTheDocument()
})

test('renders an available exercise', async () => {
  render(<ExerciseWidget exercise={exercise} track={track} />)

  expect(screen.getByRole('link')).toHaveAttribute(
    'href',
    'https://exercism.test/exercise'
  )
  expect(screen.getByRole('link')).toHaveAttribute(
    'class',
    'c-exercise-widget --available --recommended --interactive'
  )
  expect(
    screen.getByRole('img', {
      name: "Icon for exercise called Lucian's Luscious Lasagna",
    })
  ).toHaveAttribute('src', 'https://exercism.test/exercise_icon')
  expect(screen.getByText("Lucian's Luscious Lasagna")).toBeInTheDocument()
  expect(
    screen.getByRole('img', {
      name: 'icon for Ruby track',
    })
  ).toHaveAttribute('src', 'https://exercism.test/track_icon')
  expect(screen.getByText('Ruby')).toBeInTheDocument()
  expect(screen.getByText('Recommended')).toBeInTheDocument()
  expect(screen.queryByText('Locked')).not.toBeInTheDocument()
  expect(screen.getByText('Easy')).toBeInTheDocument()
  expect(screen.getByText('Tasty exercise')).toBeInTheDocument()
})

test('renders a locked exercise', async () => {
  exercise.isUnlocked = false
  exercise.isRecommended = false

  const { container } = render(
    <ExerciseWidget exercise={exercise} track={track} />
  )

  expect(container.firstChild).toHaveAttribute(
    'class',
    'c-exercise-widget --locked --interactive'
  )
  expect(screen.getByText("Lucian's Luscious Lasagna")).toBeInTheDocument()
  expect(
    screen.getByRole('img', {
      name: "Icon for exercise called Lucian's Luscious Lasagna",
    })
  ).toHaveAttribute('src', 'https://exercism.test/exercise_icon')
  expect(screen.getByText("Lucian's Luscious Lasagna")).toBeInTheDocument()
  expect(
    screen.getByRole('img', {
      name: 'icon for Ruby track',
    })
  ).toHaveAttribute('src', 'https://exercism.test/track_icon')
  expect(screen.getByText('Ruby')).toBeInTheDocument()
  expect(screen.getByText('Locked')).toBeInTheDocument()
  expect(screen.getByText('Tasty exercise')).toBeInTheDocument()
})
