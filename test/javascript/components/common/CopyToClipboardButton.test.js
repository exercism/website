import React from 'react'
import { render, waitFor, fireEvent } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { CopyToClipboardButton } from '../../../../app/javascript/components/common/CopyToClipboardButton'

const mockClipboardApi = () => {
  // The clipboard API is not supported so we have to mock it
  navigator.clipboard = { writeText: () => {} }
  jest.spyOn(navigator.clipboard, 'writeText')
}

test('copies text to clipboard when clicking', async () => {
  mockClipboardApi()

  const { getByRole } = render(
    <CopyToClipboardButton textToCopy="exercism download --track=ruby --exercise=bob" />
  )

  fireEvent.click(getByRole('img'))

  await waitFor(() =>
    expect(navigator.clipboard.writeText).toHaveBeenCalledWith(
      'exercism download --track=ruby --exercise=bob'
    )
  )
})

test('copies text to clipboard when pressing Ctrl+C', async () => {
  mockClipboardApi()

  const { queryByRole } = render(
    <CopyToClipboardButton textToCopy="exercism download --track=javascript --exercise=bob" />
  )

  const copyButton = queryByRole('button')
  copyButton.focus()

  fireEvent.keyDown(copyButton, { code: 'KeyC', ctrlKey: true })

  await waitFor(() =>
    expect(navigator.clipboard.writeText).toHaveBeenCalledWith(
      'exercism download --track=javascript --exercise=bob'
    )
  )
})

// TODO: re-enable one there is a visual indication that text was just copied
// test('changes text to copied temporarily', async () => {
//   const { getByText, queryByText } = render(
//     <CopyToClipboardButton textToCopy="exercism download --track=ruby --exercise=bob" />
//   )

//   fireEvent.click(getByText('Copy'))

//   await waitFor(() => expect(queryByText('Copied')).toBeInTheDocument())
//   await waitFor(() => expect(queryByText('Copy')).toBeInTheDocument(), {
//     timeout: 2500,
//   })
// })

test('hides component if clipboard API is unavailable', async () => {
  navigator.clipboard = undefined

  const { queryByText } = render(
    <CopyToClipboardButton textToCopy="exercism something" />
  )

  expect(queryByText('Copy')).not.toBeInTheDocument()
})
