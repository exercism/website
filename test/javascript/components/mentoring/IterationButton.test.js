import React from 'react'
import { render, screen } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { IterationButton } from '../../../../app/javascript/components/mentoring/IterationButton'

test('applies correct properties to selected button', async () => {
  render(<IterationButton idx={1} selected={true} />)

  const button = screen.getByRole('button', { name: '1' })

  expect(button).toHaveAttribute('aria-current', 'true')
  expect(button).toBeDisabled()
  expect(button).toHaveAttribute('class', 'iteration active')
})
