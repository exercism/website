import React from 'react'
import { screen, render } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import WelcomeModal from '../../../../app/javascript/components/modals/welcome-modal/WelcomeModal'
import { TestQueryCache } from '../../support/TestQueryCache'
import { queryClient } from '../../setupTests'

const links = {
  hideModalEndpoint: '',
}

test('shows the welcome view', async () => {
  render(
    <TestQueryCache queryClient={queryClient}>
      <WelcomeModal links={links} numTracks={70} ariaHideApp={false} />
    </TestQueryCache>
  )

  expect(
    await screen.findByText('Hello fellow developer 👋')
  ).toBeInTheDocument()
})
