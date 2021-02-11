import React from 'react'
import { render, screen } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { IterationsList } from '../../../../../app/javascript/components/mentoring/solution/IterationsList'

test('next iteration button is disabled when on last iteration', async () => {
  const current = { idx: 2 }
  const iterations = [{ idx: 1 }, current]

  render(<IterationsList current={current} iterations={iterations} />)

  expect(
    screen.getByRole('button', { name: 'Go to next iteration' })
  ).toBeDisabled()
})

test('previous iteration button is disabled when on first iteration', async () => {
  const current = { idx: 1 }
  const iterations = [current, { idx: 2 }]

  render(<IterationsList current={current} iterations={iterations} />)

  expect(
    screen.getByRole('button', { name: 'Go to previous iteration' })
  ).toBeDisabled()
})
