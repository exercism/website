import React from 'react'
import { render, screen } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { DonationStep } from '../../../../../../app/javascript/components/modals/student/finish-mentor-discussion-modal/DonationStep'
import { DiscussionActionsLinks } from '../../../../../../app/javascript/components/student/mentoring-session/DiscussionActions'

jest.mock('@/components/donations/Form', () => ({
  __esModule: true,
  default: () => <div>Donation form</div>,
}))

const links = {
  exercise: 'https://exercism.test/exercise',
  exerciseMentorDiscussionUrl: 'https://exercism.test/discussion',
  donationsSettings: 'https://exercism.test/settings/donations',
} as unknown as DiscussionActionsLinks

const donation = (previousDonor: boolean) => ({
  showDonationModal: true,
  previousDonor,
  request: {
    endpoint: 'https://exercism.test/donations',
    options: { initialData: {} },
  },
})

test('shows the previous donor copy to previous donors', async () => {
  render(
    <DonationStep
      donation={donation(true)}
      links={links}
      onSuccessfulDonation={jest.fn()}
    />
  )

  expect(await screen.findByText('Donation form')).toBeInTheDocument()

  expect(
    screen.getByText(/one of the few people who have donated/)
  ).toBeInTheDocument()
  expect(
    screen.queryByText(/Exercism relies on donations/)
  ).not.toBeInTheDocument()
})

test('shows the non-donor copy to people who have not donated', async () => {
  render(
    <DonationStep
      donation={donation(false)}
      links={links}
      onSuccessfulDonation={jest.fn()}
    />
  )

  expect(await screen.findByText('Donation form')).toBeInTheDocument()

  expect(screen.getByText(/Exercism relies on donations/)).toBeInTheDocument()
  expect(
    screen.queryByText(/one of the few people who have donated/)
  ).not.toBeInTheDocument()
})
