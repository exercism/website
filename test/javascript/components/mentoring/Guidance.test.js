import React from 'react'
import { render, screen } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { Guidance } from '../../../../app/javascript/components/mentoring/Guidance'

test('how you solved the exercise is open by default', async () => {
  render(<Guidance />)

  expect(
    screen.getByRole('button', { name: 'How you solved the exercise' })
  ).toHaveAttribute('aria-expanded', 'true')
  expect(screen.getByRole('button', { name: 'Mentor notes' })).toHaveAttribute(
    'aria-expanded',
    'false'
  )
  expect(
    screen.getByRole('button', { name: 'Automated feedback' })
  ).toHaveAttribute('aria-expanded', 'false')
})
