import React from 'react'
import { render, screen } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { CommitStep } from '../../../../../app/javascript/components/modals/mentor-registration-modal/CommitStep'
import userEvent from '@testing-library/user-event'

test('continue button is disabled when not everything is checked', async () => {
  render(<CommitStep links={{}} />)

  userEvent.click(
    screen.getByRole('checkbox', { name: /Abide by the Code of Conduct/ })
  )

  expect(screen.getByRole('button', { name: 'Continue' })).toBeDisabled()
})

test('continue button is enabled when all checkboxes have been checked', async () => {
  render(<CommitStep links={{}} />)

  userEvent.click(
    screen.getByRole('checkbox', { name: /Abide by the Code of Conduct/ })
  )
  userEvent.click(
    screen.getByRole('checkbox', {
      name: /Be patient, empathic and kind to those you're mentoring/,
    })
  )
  userEvent.click(
    screen.getByRole('checkbox', { name: /Demonstrate intellectual humility/ })
  )
  userEvent.click(
    screen.getByRole('checkbox', {
      name: /Not use Exercism to promote personal agendas/,
    })
  )

  expect(
    await screen.findByRole('button', { name: 'Continue' })
  ).not.toBeDisabled()
})
