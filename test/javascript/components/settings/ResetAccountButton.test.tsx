import React from 'react'
import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import '@testing-library/jest-dom/extend-expect'
import { default as ResetAccountButton } from '@/components/settings/ResetAccountButton'
import { act } from 'react-dom/test-utils'

test('closes modal when clicking on cancel', async () => {
  render(
    <ResetAccountButton handle="" links={{ reset: '' }} ariaHideApp={false} />
  )

  act(() =>
    userEvent.click(screen.getByRole('button', { name: 'Reset account' }))
  )
  act(() => userEvent.click(screen.getByRole('button', { name: 'Cancel' })))

  expect(screen.queryByRole('dialog')).not.toBeInTheDocument()
})
