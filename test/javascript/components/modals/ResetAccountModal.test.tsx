import React from 'react'
import { screen, render } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import '@testing-library/jest-dom/extend-expect'
import { ResetAccountModal } from '../../../../app/javascript/components/modals/ResetAccountModal'

test('form is disabled when handle is wrong', async () => {
  render(
    <ResetAccountModal
      open
      onClose={jest.fn()}
      handle="handle"
      endpoint=""
      ariaHideApp={false}
    />
  )

  userEvent.type(
    screen.getByLabelText(
      'To confirm, write your handle handle in the box below:'
    ),
    'wrong'
  )

  expect(screen.getByRole('button', { name: 'Reset account' })).toBeDisabled()
})

test('form is enabled when handle is correct', async () => {
  render(
    <ResetAccountModal
      open
      onClose={jest.fn()}
      handle="handle"
      endpoint=""
      ariaHideApp={false}
    />
  )

  userEvent.type(
    screen.getByLabelText(
      'To confirm, write your handle handle in the box below:'
    ),
    'handle'
  )

  expect(
    screen.getByRole('button', { name: 'Reset account' })
  ).not.toBeDisabled()
})
