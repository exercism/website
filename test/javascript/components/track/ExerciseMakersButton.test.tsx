import React from 'react'
import { render, screen } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { ExerciseMakersButton } from '../../../../app/javascript/components/track/ExerciseMakersButton'

test('hides contributors stats is numContributors is 0', async () => {
  render(
    <ExerciseMakersButton
      authors={[]}
      numContributors={0}
      links={{ contributors: '' }}
    />
  )

  expect(screen.queryByText('0 contributors')).not.toBeInTheDocument()
})
