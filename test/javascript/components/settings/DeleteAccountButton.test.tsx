import React from 'react'
import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import '@testing-library/jest-dom/extend-expect'
import { DeleteAccountButton } from '@/components/settings'
import { act } from 'react-dom/test-utils'

test('closes modal when clicking on cancel', async () => {
  render(
    <DeleteAccountButton handle="" links={{ delete: '' }} ariaHideApp={false} />
  )

  act(() =>
    userEvent.click(screen.getByRole('button', { name: 'Delete account' }))
  )
  act(() => userEvent.click(screen.getByRole('button', { name: 'Cancel' })))

  expect(screen.queryByRole('dialog')).not.toBeInTheDocument()
})
