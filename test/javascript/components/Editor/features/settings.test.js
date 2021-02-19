jest.mock('../../../../../app/javascript/components/editor/FileEditor')

import React from 'react'
import { render, fireEvent, waitFor } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { Editor } from '../../../../../app/javascript/components/Editor'

test('change theme', async () => {
  const { getByTitle, getByLabelText, queryByText } = render(
    <Editor
      files={[{ filename: 'lasagna.rb', content: 'class Lasagna' }]}
      assignment={{ overview: '', generalHints: [], tasks: [] }}
    />
  )

  fireEvent.click(getByTitle('Settings'))
  fireEvent.click(getByLabelText('Dark'))

  await waitFor(() => {
    expect(queryByText('Theme: dark')).toBeInTheDocument()
  })
})

test('change keybindings', async () => {
  const { getByTitle, getByLabelText, queryByText } = render(
    <Editor
      files={[{ filename: 'lasagna.rb', content: 'class Lasagna' }]}
      assignment={{ overview: '', generalHints: [], tasks: [] }}
    />
  )

  fireEvent.click(getByTitle('Settings'))
  fireEvent.click(getByLabelText('Vim'))
  fireEvent.click(document)

  await waitFor(() => {
    expect(queryByText('Keybindings: vim')).toBeInTheDocument()
  })
})

test('change wrapping', async () => {
  const { getByTitle, getByLabelText, queryByText } = render(
    <Editor
      files={[{ filename: 'lasagna.rb', content: 'class Lasagna' }]}
      assignment={{ overview: '', generalHints: [], tasks: [] }}
    />
  )

  fireEvent.click(getByTitle('Settings'))
  fireEvent.click(getByLabelText('Off'))

  await waitFor(() => {
    expect(queryByText('Wrap: off')).toBeInTheDocument()
  })
})
