import React from 'react'
import { render, screen } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { Contribution } from '../../../../app/javascript/components/journey/Contribution'

test('renders "Generic" when track is not present', async () => {
  render(<Contribution track={undefined} />)

  expect(screen.getByText('Generic')).toBeInTheDocument()
})

test('renders internal link over external link', async () => {
  render(<Contribution internalUrl="link" externalUrl="external" />)

  expect(screen.getByRole('link')).toHaveAttribute('href', 'link')
})

test('renders external link if no internal link', async () => {
  render(<Contribution externalUrl="link" />)

  expect(screen.getByRole('link')).toHaveAttribute('href', 'link')
})

test('renders no link if external and internal link are not present', async () => {
  render(<Contribution />)

  expect(screen.queryByRole('link')).not.toBeInTheDocument()
})

test('hides icon if external and internal link are not present', async () => {
  render(<Contribution />)

  expect(screen.queryByAltText('Open link')).not.toBeInTheDocument()
})
