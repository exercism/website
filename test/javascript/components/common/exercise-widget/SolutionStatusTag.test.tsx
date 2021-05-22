import React from 'react'
import { render, screen } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { SolutionStatusTag } from '../../../../../app/javascript/components/common/exercise-widget/SolutionStatusTag'

test('renders Published when status is published', async () => {
  const { container } = render(
    <SolutionStatusTag status="published" size="small" />
  )

  expect(container.firstChild).toHaveAttribute(
    'class',
    'c-exercise-status-tag --published --small'
  )
  expect(screen.getByText('Published')).toBeInTheDocument()
})

test('renders Completed when status is completed', async () => {
  const { container } = render(
    <SolutionStatusTag status="completed" size="small" />
  )

  expect(container.firstChild).toHaveAttribute(
    'class',
    'c-exercise-status-tag --completed --small'
  )
  expect(screen.getByText('Completed')).toBeInTheDocument()
})

test('renders in progress when status is iterated', async () => {
  const { container } = render(
    <SolutionStatusTag status="iterated" size="small" />
  )

  expect(container.firstChild).toHaveAttribute(
    'class',
    'c-exercise-status-tag --in-progress --small'
  )
  expect(screen.getByText('In-progress')).toBeInTheDocument()
})

test('renders in progress when status is started', async () => {
  const { container } = render(
    <SolutionStatusTag status="started" size="small" />
  )

  expect(container.firstChild).toHaveAttribute(
    'class',
    'c-exercise-status-tag --in-progress --small'
  )
  expect(screen.getByText('In-progress')).toBeInTheDocument()
})
