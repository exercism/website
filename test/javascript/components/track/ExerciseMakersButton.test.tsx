import React from 'react'
import { render, screen } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { ExerciseMakersButton } from '../../../../app/javascript/components/track/ExerciseMakersButton'

test('shows correctly', async () => {
  render(
    <ExerciseMakersButton
      avatarUrls={[]}
      numAuthors={1}
      numContributors={2}
      links={{ makers: '' }}
    />
  )

  expect(screen.queryByText('1 author')).toBeInTheDocument()
  expect(screen.queryByText('2 contributors')).toBeInTheDocument()
})

test('hides contributors stats is numContributors is 0', async () => {
  render(
    <ExerciseMakersButton
      avatarUrls={[]}
      numContributors={0}
      links={{ makers: '' }}
    />
  )

  expect(screen.queryByText('0 contributors')).not.toBeInTheDocument()
})
