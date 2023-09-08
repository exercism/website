import React from 'react'
import { render, screen } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { ActionIcon } from '../../../../../../app/javascript/components/contributing/tasks-list/task/ActionIcon'

test('renders a GraphicalIcon if action is not specified', () => {
  render(<ActionIcon />)

  const img = screen.queryByRole('img')
  expect(img).toBeInTheDocument()

  const altAttribute = img?.getAttribute('alt')
  expect(altAttribute).not.toContain('Action:')
})
