import React from 'react'
import { render, screen } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { Contribution } from '../../../../app/javascript/components/journey/Contribution'

test('renders "Generic" when track is not present', async () => {
  render(<Contribution track={undefined} />)

  expect(screen.getByText('Generic')).toBeInTheDocument()
})
