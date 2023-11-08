import React from 'react'
import { render, screen } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { ExerciseMakersButton } from '../../../../app/javascript/components/track/ExerciseMakersButton'
import { TestQueryCache } from '../../support/TestQueryCache'
import { queryClient } from '../../setupTests'

test('shows correctly', async () => {
  render(
    <TestQueryCache queryClient={queryClient}>
      <ExerciseMakersButton
        avatarUrls={[]}
        numAuthors={1}
        numContributors={2}
        links={{ makers: '' }}
      />
    </TestQueryCache>
  )

  expect(screen.queryByText('1 author')).toBeInTheDocument()
  expect(screen.queryByText('2 contributors')).toBeInTheDocument()
})

test('hides contributors stats is numContributors is 0', async () => {
  render(
    <TestQueryCache queryClient={queryClient}>
      <ExerciseMakersButton
        avatarUrls={[]}
        numContributors={0}
        links={{ makers: '' }}
        numAuthors={0}
      />
    </TestQueryCache>
  )

  expect(screen.queryByText('0 contributors')).not.toBeInTheDocument()
})
