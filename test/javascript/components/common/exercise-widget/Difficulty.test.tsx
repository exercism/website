import React from 'react'
import { render, screen } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { Difficulty } from '../../../../../app/javascript/components/common/exercise-widget/Difficulty'

test('renders Easy when difficulty is easy', async () => {
  const { container } = render(<Difficulty difficulty="easy" />)

  expect(container.firstChild).toHaveAttribute('class', '--difficulty --easy')
  expect(screen.getByText('Easy')).toBeInTheDocument()
})
