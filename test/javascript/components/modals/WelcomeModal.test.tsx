import React from 'react'
import { screen, render } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import WelcomeModal from '../../../../app/javascript/components/modals/welcome-modal/WelcomeModal'
import { TestQueryCache } from '../../support/TestQueryCache'
import { queryClient } from '../../setupTests'

const links = {
  hideModalEndpoint: '',
  apiUserEndpoint: '',
  jiki: '',
}

test('asks how experienced the user is by default', async () => {
  render(
    <TestQueryCache queryClient={queryClient}>
      <WelcomeModal links={links} numTracks={70} ariaHideApp={false} />
    </TestQueryCache>
  )

  expect(
    await screen.findByText('How experienced a developer are you?')
  ).toBeInTheDocument()
})

test('skips the seniority question when told not to ask', async () => {
  render(
    <TestQueryCache queryClient={queryClient}>
      <WelcomeModal
        links={links}
        numTracks={70}
        askSeniority={false}
        ariaHideApp={false}
      />
    </TestQueryCache>
  )

  expect(
    await screen.findByText('Hello fellow developer 👋')
  ).toBeInTheDocument()
  expect(
    screen.queryByText('How experienced a developer are you?')
  ).not.toBeInTheDocument()
})
