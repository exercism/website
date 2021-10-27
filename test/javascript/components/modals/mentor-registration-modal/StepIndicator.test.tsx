import React from 'react'
import { render, screen } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { StepIndicator } from '../../../../../app/javascript/components/modals/mentor-registration-modal/StepIndicator'
import { StepProps } from '../../../../../app/javascript/components/modals/MentorRegistrationModal'

test('shows steps', async () => {
  const steps: StepProps[] = [
    {
      id: 'CHOOSE_TRACK',
      label: 'Select the tracks you want to mentor',
    },
    {
      id: 'COMMIT',
      label: 'Commit to being a good mentor',
    },
  ]
  render(<StepIndicator steps={steps} currentStep="CHOOSE_TRACK" />)

  expect(
    screen.getByText('Step 1: Select the tracks you want to mentor')
  ).toBeInTheDocument()
  expect(
    screen.getByText('Step 2: Commit to being a good mentor')
  ).toBeInTheDocument()
})

test('shows current step', async () => {
  const steps: StepProps[] = [
    {
      id: 'CHOOSE_TRACK',
      label: 'Select the tracks you want to mentor',
    },
    {
      id: 'COMMIT',
      label: 'Commit to being a good mentor',
    },
  ]
  render(<StepIndicator steps={steps} currentStep="COMMIT" />)

  expect(
    screen.getByText('Step 2: Commit to being a good mentor').parentNode
  ).toHaveAttribute('aria-current', 'step')
  expect(
    screen.getByText('Step 2: Commit to being a good mentor').parentNode
  ).toHaveAttribute('class', 'step selected')
})
