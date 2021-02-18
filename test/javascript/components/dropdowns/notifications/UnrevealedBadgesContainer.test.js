import React from 'react'
import { render, screen } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { UnrevealedBadgesContainer } from '../../../../../app/javascript/components/dropdowns/notifications/UnrevealedBadgesContainer'

test('shows message when 1 badge is unrevealed', async () => {
  const badges = [{ rarity: 'common' }]

  render(
    <UnrevealedBadgesContainer
      badges={badges}
      url="https://exercism.io/badges"
    />
  )

  expect(screen.getByText("You've earned a new badge!")).toBeInTheDocument()
})

test('shows message when multiple badges are unrevealed', async () => {
  const badges = [{ rarity: 'common' }, { rarity: 'common' }]

  render(
    <UnrevealedBadgesContainer
      badges={badges}
      url="https://exercism.io/badges"
    />
  )

  expect(screen.getByText("You've earned new badges!")).toBeInTheDocument()
})

test('shows nothing when no badges are unrevealed', async () => {
  const badges = []

  render(
    <UnrevealedBadgesContainer
      badges={badges}
      url="https://exercism.io/badges"
    />
  )

  expect(screen.queryByRole('link')).not.toBeInTheDocument()
})
