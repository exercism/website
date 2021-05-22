import React from 'react'
import { render, screen } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { Difficulty } from '../../../../../app/javascript/components/common/exercise-widget/Difficulty'

test('renders Easy when difficulty is easy', async () => {
  const { container } = render(<Difficulty difficulty="easy" size="small" />)

  expect(container.firstChild).toHaveAttribute(
    'class',
    'c-difficulty-tag --easy --small'
  )
  expect(screen.getByText('Easy')).toBeInTheDocument()
})
