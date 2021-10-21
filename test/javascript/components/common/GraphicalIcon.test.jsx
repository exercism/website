import React from 'react'
import { render, waitFor, screen } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { GraphicalIcon } from '../../../../app/javascript/components/common/GraphicalIcon'

test('icon renders correctly', async () => {
  render(<GraphicalIcon icon="reputation" />)

  await waitFor(() =>
    expect(screen.queryByRole('presentation')).toBeInTheDocument()
  )
})
