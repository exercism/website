import React from 'react'
import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { EndSessionButton } from '../../../../../app/javascript/components/mentoring/discussion/EndSessionButton'
import '@testing-library/jest-dom/extend-expect'

test('clicking cancel hides modal', async () => {
  render(<EndSessionButton modalProps={{ ariaHideApp: false }} />)

  userEvent.click(screen.getByRole('button', { name: 'End session' }))
  userEvent.click(await screen.findByRole('button', { name: 'Cancel' }))

  expect(screen.queryByRole('dialog')).not.toBeInTheDocument()
})
