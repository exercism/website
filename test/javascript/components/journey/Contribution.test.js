import React from 'react'
import { render, screen } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { Contribution } from '../../../../app/javascript/components/journey/Contribution'

test('renders "Generic" when track is not present', async () => {
  render(<Contribution track={undefined} />)

  expect(screen.getByText('Generic')).toBeInTheDocument()
})

test('renders internal link over extenal link', async () => {
  render(<Contribution internalLink="link" externalLink="external" />)

  expect(screen.getByRole('link')).toHaveAttribute('href', 'link')
})

test('renders external link if no internal link', async () => {
  render(<Contribution externalLink="link" />)

  expect(screen.getByRole('link')).toHaveAttribute('href', 'link')
})
