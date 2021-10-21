import React from 'react'
import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { FinishButton } from '../../../../../app/javascript/components/mentoring/discussion/FinishButton'
import '@testing-library/jest-dom/extend-expect'

test('clicking cancel hides modal', async () => {
  render(<FinishButton modalProps={{ ariaHideApp: false }} />)

  userEvent.click(screen.getByRole('button', { name: 'End discussion' }))
  userEvent.click(await screen.findByRole('button', { name: 'Cancel' }))

  expect(screen.queryByRole('dialog')).not.toBeInTheDocument()
})
