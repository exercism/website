jest.mock('../../../../../app/javascript/components/editor/FileEditor')

import React from 'react'
import { render, fireEvent, waitFor, screen } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { Editor } from '../../../../../app/javascript/components/Editor'

test('change theme', async () => {
  render(
    <Editor
      files={[{ filename: 'lasagna.rb', content: 'class Lasagna' }]}
      assignment={{ overview: '', generalHints: [], tasks: [] }}
    />
  )

  fireEvent.click(screen.getByAltText('Settings'))
  fireEvent.click(screen.getByLabelText('Dark'))

  await waitFor(() => {
    expect(screen.queryByText('Theme: dark')).toBeInTheDocument()
  })
})

test('change keybindings', async () => {
  render(
    <Editor
      files={[{ filename: 'lasagna.rb', content: 'class Lasagna' }]}
      assignment={{ overview: '', generalHints: [], tasks: [] }}
    />
  )

  fireEvent.click(screen.getByAltText('Settings'))
  fireEvent.click(screen.getByLabelText('Vim'))
  fireEvent.click(document)

  await waitFor(() => {
    expect(screen.queryByText('Keybindings: vim')).toBeInTheDocument()
  })
})

test('change wrapping', async () => {
  render(
    <Editor
      files={[{ filename: 'lasagna.rb', content: 'class Lasagna' }]}
      assignment={{ overview: '', generalHints: [], tasks: [] }}
    />
  )

  fireEvent.click(screen.getByAltText('Settings'))
  fireEvent.click(screen.getByLabelText('Off'))

  await waitFor(() => {
    expect(screen.queryByText('Wrap: off')).toBeInTheDocument()
  })
})
