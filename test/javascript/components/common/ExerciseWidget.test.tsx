import React from 'react'
import { render, screen } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { ExerciseWidget } from '../../../../app/javascript/components/common/ExerciseWidget'
import { Exercise } from '../../../../app/javascript/components/types'

test('renders an available exercise', async () => {
  const exercise: Exercise = {
    slug: 'lasagna',
    title: "Lucian's Luscious Lasagna",
    iconUrl: 'https://exercism.test/icon',
    blurb: 'Tasty exercise',
    difficulty: 'easy',
    isAvailable: true,
    links: {
      self: 'https://exercism.test/exercise',
    },
  }

  render(<ExerciseWidget exercise={exercise} />)

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
  }

  render(<ExerciseWidget exercise={exercise} />)

  expect(screen.getByText('Locked')).toBeInTheDocument()
  expect(screen.queryByText('Available')).not.toBeInTheDocument()
  expect(screen.queryByRole('link')).not.toBeInTheDocument()
})
