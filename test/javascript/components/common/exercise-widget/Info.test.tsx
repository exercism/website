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
    type: 'practice',
    title: "Lucian's Luscious Lasagna",
    iconUrl: 'https://exercism.test/exercise_icon',
    blurb: 'Tasty exercise',
    difficulty: 'easy',
    isUnlocked: true,
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
    type: 'practice',
    title: "Lucian's Luscious Lasagna",
    iconUrl: 'https://exercism.test/exercise_icon',
    blurb: 'Tasty exercise',
    difficulty: 'easy',
    isUnlocked: true,
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
    type: 'practice',
    title: "Lucian's Luscious Lasagna",
    iconUrl: 'https://exercism.test/exercise_icon',
    blurb: 'Tasty exercise',
    difficulty: 'easy',
    isUnlocked: true,
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
    type: 'practice',
    title: "Lucian's Luscious Lasagna",
    iconUrl: 'https://exercism.test/exercise_icon',
    blurb: 'Tasty exercise',
    difficulty: 'easy',
    isUnlocked: true,
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
    type: 'practice',
    title: "Lucian's Luscious Lasagna",
    iconUrl: 'https://exercism.test/exercise_icon',
    blurb: 'Tasty exercise',
    difficulty: 'easy',
    isUnlocked: true,
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
    type: 'practice',
    title: "Lucian's Luscious Lasagna",
    iconUrl: 'https://exercism.test/exercise_icon',
    blurb: 'Tasty exercise',
    difficulty: 'easy',
    isUnlocked: true,
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
    type: 'practice',
    title: "Lucian's Luscious Lasagna",
    iconUrl: 'https://exercism.test/exercise_icon',
    blurb: 'Tasty exercise',
    difficulty: 'easy',
    isUnlocked: true,
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

test('renders type not difficulty if concept', async () => {
  const exercise: Exercise = {
    slug: 'lasagna',
    type: 'concept',
    title: "Lucian's Luscious Lasagna",
    iconUrl: 'https://exercism.test/exercise_icon',
    blurb: 'Tasty exercise',
    difficulty: 'easy',
    isUnlocked: true,
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

  expect(screen.queryByText('Easy')).not.toBeInTheDocument()
  expect(screen.queryByText('Learning Exercise')).toBeInTheDocument()
})

test('renders number of iterations when solution has more than 0', async () => {
  const exercise: Exercise = {
    slug: 'lasagna',
    type: 'practice',
    title: "Lucian's Luscious Lasagna",
    iconUrl: 'https://exercism.test/exercise_icon',
    blurb: 'Tasty exercise',
    difficulty: 'easy',
    isUnlocked: true,
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
    type: 'practice',
    title: "Lucian's Luscious Lasagna",
    iconUrl: 'https://exercism.test/exercise_icon',
    blurb: 'Tasty exercise',
    difficulty: 'easy',
    isUnlocked: true,
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
    isUnlocked: true,
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

test('renders mentoring requested', async () => {
  const exercise: Exercise = {
    slug: 'lasagna',
    title: "Lucian's Luscious Lasagna",
    iconUrl: 'https://exercism.test/exercise_icon',
    blurb: 'Tasty exercise',
    difficulty: 'easy',
    isUnlocked: true,
    isRecommended: true,
    links: {
      self: 'https://exercism.test/exercise',
    },
  }
  const solution: SolutionForStudent = {
    url: 'https://exercism.test/solution',
    status: 'completed',
    mentoringStatus: 'requested',
    exercise: { slug: 'ruby' },
  }
  const track: Track = {
    id: '1',
    title: 'Ruby',
    iconUrl: 'https://exercism.test/track_icon',
  }

  render(<Info exercise={exercise} track={track} solution={solution} />)

  expect(screen.getByAltText('Mentoring requested')).toBeInTheDocument()
})
test('renders mentoring in progress', async () => {
  const exercise: Exercise = {
    slug: 'lasagna',
    title: "Lucian's Luscious Lasagna",
    iconUrl: 'https://exercism.test/exercise_icon',
    blurb: 'Tasty exercise',
    difficulty: 'easy',
    isUnlocked: true,
    isRecommended: true,
    links: {
      self: 'https://exercism.test/exercise',
    },
  }
  const solution: SolutionForStudent = {
    url: 'https://exercism.test/solution',
    status: 'completed',
    mentoringStatus: 'in_progress',
    exercise: { slug: 'ruby' },
  }
  const track: Track = {
    id: '1',
    title: 'Ruby',
    iconUrl: 'https://exercism.test/track_icon',
  }

  render(<Info exercise={exercise} track={track} solution={solution} />)

  expect(screen.getByAltText('Mentoring in progress')).toBeInTheDocument()
})
test('renders mentoring finished', async () => {
  const exercise: Exercise = {
    slug: 'lasagna',
    title: "Lucian's Luscious Lasagna",
    iconUrl: 'https://exercism.test/exercise_icon',
    blurb: 'Tasty exercise',
    difficulty: 'easy',
    isUnlocked: true,
    isRecommended: true,
    links: {
      self: 'https://exercism.test/exercise',
    },
  }
  const solution: SolutionForStudent = {
    url: 'https://exercism.test/solution',
    status: 'completed',
    mentoringStatus: 'finished',
    exercise: { slug: 'ruby' },
  }
  const track: Track = {
    id: '1',
    title: 'Ruby',
    iconUrl: 'https://exercism.test/track_icon',
  }

  render(<Info exercise={exercise} track={track} solution={solution} />)

  expect(screen.getByAltText('Mentoring finished')).toBeInTheDocument()
})

test('does not render number of mentoring comments when solution has 0', async () => {
  const exercise: Exercise = {
    slug: 'lasagna',
    title: "Lucian's Luscious Lasagna",
    iconUrl: 'https://exercism.test/exercise_icon',
    blurb: 'Tasty exercise',
    difficulty: 'easy',
    isUnlocked: true,
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
    isUnlocked: true,
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
