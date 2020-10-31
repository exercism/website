import React from 'react'
import { render, waitFor, fireEvent } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { CopyToClipboardButton } from '../../../../app/javascript/components/common/CopyToClipboardButton'

test('copies text to clipboard when clicking', async () => {
  // The clipboard API is not supported so we have to mock it
  navigator.clipboard = { writeText: () => {} }
  jest.spyOn(navigator.clipboard, 'writeText')

  const { getByText } = render(
    <CopyToClipboardButton textToCopy="exercism download --track=ruby --exercise=bob" />
  )

  fireEvent.click(getByText('Copy'))

  await waitFor(() =>
    expect(navigator.clipboard.writeText).toHaveBeenCalledWith(
      'exercism download --track=ruby --exercise=bob'
    )
  )
})

test('changes text to copied temporarily', async () => {
  const { getByText, queryByText } = render(
    <CopyToClipboardButton textToCopy="exercism download --track=ruby --exercise=bob" />
  )

  fireEvent.click(getByText('Copy'))

  await waitFor(() => expect(queryByText('Copied')).toBeInTheDocument())
  await waitFor(() => expect(queryByText('Copy')).toBeInTheDocument(), {
    timeout: 2500,
  })
})

test('hides component if clipboard API is unavailable', async () => {
  navigator.clipboard = undefined

  const { queryByText } = render(
    <CopyToClipboardButton textToCopy="exercism download --track=ruby --exercise=bob" />
  )

  expect(queryByText('Copy')).not.toBeInTheDocument()
})
