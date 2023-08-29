import React from 'react'
import { render, waitFor, fireEvent, screen } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import CopyToClipboardButton from '@/components/common/CopyToClipboardButton'

// See https://github.com/aelbore/esbuild-jest/issues/26
jest.mock('@/utils/copyToClipboard', () => ({
  copyToClipboard: jest.fn(),
}))

import { copyToClipboard } from '@/utils/copyToClipboard'

test('copies text to clipboard when clicking', async () => {
  const { getByRole } = render(
    <CopyToClipboardButton textToCopy="exercism download --track=ruby --exercise=bob" />
  )

  fireEvent.click(getByRole('img'))

  await waitFor(() =>
    expect(copyToClipboard).toHaveBeenCalledWith(
      'exercism download --track=ruby --exercise=bob'
    )
  )
})

test('copies text to clipboard when pressing Ctrl+C', async () => {
  const { queryByRole } = render(
    <CopyToClipboardButton textToCopy="exercism download --track=javascript --exercise=bob" />
  )

  const copyButton = queryByRole('button')
  copyButton.focus()

  fireEvent.keyDown(copyButton, { code: 'KeyC', ctrlKey: true })

  await waitFor(() =>
    expect(copyToClipboard).toHaveBeenCalledWith(
      'exercism download --track=javascript --exercise=bob'
    )
  )
})

test('changes text to copied temporarily', async () => {
  const { queryByRole } = render(
    <CopyToClipboardButton textToCopy="exercism download --track=javascript --exercise=bob" />
  )

  const copyButton = queryByRole('button')
  copyButton.focus()

  fireEvent.keyDown(copyButton, { code: 'KeyC', ctrlKey: true })

  await waitFor(() => expect(screen.queryByText('Copied')).toBeInTheDocument())
  await waitFor(() =>
    expect(screen.queryByText('Copied')).not.toBeInTheDocument()
  )
})
