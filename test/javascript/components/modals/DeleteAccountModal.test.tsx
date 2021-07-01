import React from 'react'
import { screen, render } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import '@testing-library/jest-dom/extend-expect'
import { DeleteAccountModal } from '../../../../app/javascript/components/modals/DeleteAccountModal'

test('form is disabled when handle is wrong', async () => {
  render(
    <DeleteAccountModal
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

  expect(screen.getByRole('button', { name: 'Delete account' })).toBeDisabled()
})

test('form is enabled when handle is correct', async () => {
  render(
    <DeleteAccountModal
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
    screen.getByRole('button', { name: 'Delete account' })
  ).not.toBeDisabled()
})
