import React from 'react'
import { screen, render, waitFor } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { Icon } from '../../../../app/javascript/components/common/Icon'

test('icon renders correctly', async () => {
  render(<Icon icon="reputation" alt="Reputation" />)

  await waitFor(() => expect(screen.queryByRole('img')).toBeInTheDocument())
  await waitFor(() =>
    expect(screen.queryByAltText('Reputation')).toBeInTheDocument()
  )
})
