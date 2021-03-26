import React from 'react'
import { render, screen } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { Info } from '../../../../../app/javascript/components/common/exercise-widget/Info'
import {
  Exercise,
  SolutionForStudent,
  Track,
} from '../../../../../app/javascript/components/types'

test('renders has notifications when solution has notifications', async () => {
  const exercise: Exercise = {
    slug: 'lasagna',
    title: "Lucian's Luscious Lasagna",
    iconUrl: 'https://exercism.test/exercise_icon',
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
    numMentoringComments: 2,
    numIterations: 3,
  }
  const track: Track = {
    id: '1',
    title: 'Ruby',
    iconUrl: 'https://exercism.test/track_icon',
  }

  render(<Info exercise={exercise} track={track} solution={solution} />)

  expect(screen.getByText('has notifications')).toBeInTheDocument()
})

test('does not render has notifications when solution has no notifications', async () => {
  const exercise: Exercise = {
    slug: 'lasagna',
    title: "Lucian's Luscious Lasagna",
    iconUrl: 'https://exercism.test/exercise_icon',
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
    hasNotifications: false,
    exercise: {
      slug: 'ruby',
    },
    numMentoringComments: 2,
    numIterations: 3,
  }
  const track: Track = {
    id: '1',
    title: 'Ruby',
    iconUrl: 'https://exercism.test/track_icon',
  }

  render(<Info exercise={exercise} track={track} solution={solution} />)

  expect(screen.queryByText('has notifications')).not.toBeInTheDocument()
})

test('does not render has notifications when ther is no solution', async () => {
  const exercise: Exercise = {
    slug: 'lasagna',
    title: "Lucian's Luscious Lasagna",
    iconUrl: 'https://exercism.test/exercise_icon',
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
    iconUrl: 'https://exercism.test/track_icon',
  }

  render(<Info exercise={exercise} track={track} />)

  expect(screen.queryByText('has notifications')).not.toBeInTheDocument()
})

test('renders solution status when passed in', async () => {
  const exercise: Exercise = {
    slug: 'lasagna',
    title: "Lucian's Luscious Lasagna",
    iconUrl: 'https://exercism.test/exercise_icon',
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
    numMentoringComments: 2,
    numIterations: 3,
  }
  const track: Track = {
    id: '1',
    title: 'Ruby',
    iconUrl: 'https://exercism.test/track_icon',
  }

  render(<Info exercise={exercise} track={track} solution={solution} />)

  expect(screen.getByText('Completed')).toBeInTheDocument()
})

test('renders exercise status when there is no solution', async () => {
  const exercise: Exercise = {
    slug: 'lasagna',
    title: "Lucian's Luscious Lasagna",
    iconUrl: 'https://exercism.test/exercise_icon',
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
    iconUrl: 'https://exercism.test/track_icon',
  }

  render(<Info exercise={exercise} track={track} />)

  expect(screen.getByText('Recommended')).toBeInTheDocument()
})

test('renders exercise difficulty when there is no solution', async () => {
  const exercise: Exercise = {
    slug: 'lasagna',
    title: "Lucian's Luscious Lasagna",
    iconUrl: 'https://exercism.test/exercise_icon',
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
    iconUrl: 'https://exercism.test/track_icon',
  }

  render(<Info exercise={exercise} track={track} />)

  expect(screen.getByText('Easy')).toBeInTheDocument()
})

test('does not render exercise difficulty when solution is passed in', async () => {
  const exercise: Exercise = {
    slug: 'lasagna',
    title: "Lucian's Luscious Lasagna",
    iconUrl: 'https://exercism.test/exercise_icon',
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
    numMentoringComments: 2,
    numIterations: 3,
  }
  const track: Track = {
    id: '1',
    title: 'Ruby',
    iconUrl: 'https://exercism.test/track_icon',
  }

  render(<Info exercise={exercise} track={track} solution={solution} />)

  expect(screen.queryByText('Easy')).not.toBeInTheDocument()
})

test('renders number of iterations when solution has more than 0', async () => {
  const exercise: Exercise = {
    slug: 'lasagna',
    title: "Lucian's Luscious Lasagna",
    iconUrl: 'https://exercism.test/exercise_icon',
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
    numMentoringComments: 2,
    numIterations: 3,
  }
  const track: Track = {
    id: '1',
    title: 'Ruby',
    iconUrl: 'https://exercism.test/track_icon',
  }

  render(<Info exercise={exercise} track={track} solution={solution} />)

  expect(screen.getByText('3 iterations')).toBeInTheDocument()
})

test('does not render number of iterations when solution has 0', async () => {
  const exercise: Exercise = {
    slug: 'lasagna',
    title: "Lucian's Luscious Lasagna",
    iconUrl: 'https://exercism.test/exercise_icon',
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
    numMentoringComments: 2,
    numIterations: 0,
  }
  const track: Track = {
    id: '1',
    title: 'Ruby',
    iconUrl: 'https://exercism.test/track_icon',
  }

  render(<Info exercise={exercise} track={track} solution={solution} />)

  expect(screen.queryByText('0 iterations')).not.toBeInTheDocument()
})

test('does not render number of iterations when there is no solution', async () => {
  const exercise: Exercise = {
    slug: 'lasagna',
    title: "Lucian's Luscious Lasagna",
    iconUrl: 'https://exercism.test/exercise_icon',
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
    iconUrl: 'https://exercism.test/track_icon',
  }

  render(<Info exercise={exercise} track={track} />)

  expect(screen.queryByText('iteration')).not.toBeInTheDocument()
})

test('renders number of mentoring comments when solution has more than 0', async () => {
  const exercise: Exercise = {
    slug: 'lasagna',
    title: "Lucian's Luscious Lasagna",
    iconUrl: 'https://exercism.test/exercise_icon',
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
    numMentoringComments: 2,
    numIterations: 3,
  }
  const track: Track = {
    id: '1',
    title: 'Ruby',
    iconUrl: 'https://exercism.test/track_icon',
  }

  render(<Info exercise={exercise} track={track} solution={solution} />)

  expect(screen.getByText('2')).toBeInTheDocument()
})

test('does not render number of mentoring comments when solution has 0', async () => {
  const exercise: Exercise = {
    slug: 'lasagna',
    title: "Lucian's Luscious Lasagna",
    iconUrl: 'https://exercism.test/exercise_icon',
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
    numMentoringComments: 0,
    numIterations: 0,
  }
  const track: Track = {
    id: '1',
    title: 'Ruby',
    iconUrl: 'https://exercism.test/track_icon',
  }

  render(<Info exercise={exercise} track={track} solution={solution} />)

  expect(screen.queryByText('0')).not.toBeInTheDocument()
})

test('does not render number of mentoring comments when there is no solution', async () => {
  const exercise: Exercise = {
    slug: 'lasagna',
    title: "Lucian's Luscious Lasagna",
    iconUrl: 'https://exercism.test/exercise_icon',
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
    iconUrl: 'https://exercism.test/track_icon',
  }

  render(<Info exercise={exercise} track={track} />)

  expect(screen.queryByText('0')).not.toBeInTheDocument()
})
