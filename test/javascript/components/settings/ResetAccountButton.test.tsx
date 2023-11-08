import React from 'react'
import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import '@testing-library/jest-dom/extend-expect'
import { default as ResetAccountButton } from '@/components/settings/ResetAccountButton'
import { act } from 'react-dom/test-utils'
import { TestQueryCache } from '../../support/TestQueryCache'
import { queryClient } from '../../setupTests'

test('closes modal when clicking on cancel', async () => {
  render(
    <TestQueryCache queryClient={queryClient}>
      <ResetAccountButton handle="" links={{ reset: '' }} ariaHideApp={false} />
    </TestQueryCache>
  )

  act(() =>
    userEvent.click(screen.getByRole('button', { name: 'Reset account' }))
  )
  act(() => userEvent.click(screen.getByRole('button', { name: 'Cancel' })))

  expect(screen.queryByRole('dialog')).not.toBeInTheDocument()
})
