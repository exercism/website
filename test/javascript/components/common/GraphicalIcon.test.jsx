import React from 'react'
import { render, screen } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { GraphicalIcon } from '../../../../app/javascript/components/common/GraphicalIcon'

test('icon renders correctly', async () => {
  render(<GraphicalIcon icon="reputation" alt="GraphicalIcon's alt text" />)

  const icon = await screen.findByAltText("GraphicalIcon's alt text")
  expect(icon).toBeInTheDocument()
})
