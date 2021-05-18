import React from 'react'
import { render, screen } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { ExerciseContributors } from '../../../../app/javascript/components/track/ExerciseContributors'

test('hides contributors stats is numContributors is 0', async () => {
  render(
    <ExerciseContributors
      authors={[]}
      numContributors={0}
      links={{ contributors: '' }}
    />
  )

  expect(screen.queryByText('0 contributors')).not.toBeInTheDocument()
})
