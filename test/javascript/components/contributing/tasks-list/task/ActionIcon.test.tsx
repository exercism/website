import React from 'react'
import { render, screen } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { ActionIcon } from '../../../../../../app/javascript/components/contributing/tasks-list/task/ActionIcon'

test('renders an empty div when action is empty', () => {
  render(<ActionIcon />)

  expect(screen.queryByRole('img')).not.toBeInTheDocument()
})
