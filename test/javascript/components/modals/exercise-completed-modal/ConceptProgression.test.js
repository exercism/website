import React from 'react'
import { render, screen } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { ConceptProgression } from '../../../../../app/javascript/components/modals/exercise-completed-modal/ConceptProgression'

test('shows completed progress bar if mastered', async () => {
  render(<ConceptProgression name="Arrays" from={4} to={5} total={5} />)

  expect(screen.getByRole('progressbar')).toHaveAttribute(
    'class',
    'c-concept-progress-bar completed'
  )
})

test('shows not completed progress bar if not mastered', async () => {
  render(<ConceptProgression name="Arrays" from={4} to={5} total={6} />)

  expect(screen.getByRole('progressbar')).toHaveAttribute(
    'class',
    'c-concept-progress-bar'
  )
})

test('shows completed icon if mastered', async () => {
  render(<ConceptProgression name="Arrays" from={4} to={5} total={5} />)

  expect(
    screen.getByRole('img', { name: 'Concept completed' })
  ).toBeInTheDocument()
})

test('hides shows completed icon if not mastered', async () => {
  render(<ConceptProgression name="Arrays" from={4} to={5} total={6} />)

  expect(
    screen.queryByRole('img', { name: 'Concept completed' })
  ).not.toBeInTheDocument()
})
