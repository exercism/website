import React from 'react'
import { render, screen } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { IterationButton } from '../../../../app/javascript/components/mentoring/IterationButton'

test('applies correct properties to selected button', async () => {
  const iteration = { idx: 1 }
  render(<IterationButton iteration={iteration} selected={true} />)

  const button = screen.getByRole('button', { name: 'Go to iteration 1' })

  expect(button).toHaveAttribute('aria-current', 'true')
  expect(button).toBeDisabled()
  expect(button).toHaveAttribute('class', 'iteration active')
})

test('applies correct labels when numComments = 0', async () => {
  const iteration = { idx: 1, numComments: 0 }
  render(<IterationButton iteration={iteration} selected={true} />)

  expect(
    screen.getByRole('button', { name: 'Go to iteration 1' })
  ).toBeInTheDocument()
  expect(screen.queryByText('0')).not.toBeInTheDocument()
})

test('applies correct labels when numComments <= 9', async () => {
  const iteration = { idx: 1, numComments: 4 }
  render(<IterationButton iteration={iteration} selected={true} />)

  expect(
    screen.getByRole('button', { name: 'Go to iteration 1, 4 comments' })
  ).toBeInTheDocument()
  expect(screen.getByText('4')).toBeInTheDocument()
})

test('applies correct labels when numComments > 9', async () => {
  const iteration = { idx: 1, numComments: 10 }
  render(<IterationButton iteration={iteration} selected={true} />)

  expect(
    screen.getByRole('button', { name: 'Go to iteration 1, 9+ comments' })
  ).toBeInTheDocument()
  expect(screen.getByText('9+')).toBeInTheDocument()
})
