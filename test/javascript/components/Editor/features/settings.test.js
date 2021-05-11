jest.mock('../../../../../app/javascript/components/editor/FileEditorAce')

import React from 'react'
import { render, fireEvent, waitFor, screen } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { Editor } from '../../../../../app/javascript/components/Editor'
import userEvent from '@testing-library/user-event'
import { act } from 'react-dom/test-utils'
import { awaitPopper } from '../../../support/await-popper'

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
    expect(screen.queryByText('Theme: cobalt')).toBeInTheDocument()
  })
})

test('change keybindings', async () => {
  render(
    <Editor
      files={[{ filename: 'lasagna.rb', content: 'class Lasagna' }]}
      assignment={{ overview: '', generalHints: [], tasks: [] }}
    />
  )

  userEvent.click(screen.getByAltText('Settings'))
  userEvent.click(await screen.findByLabelText('Vim'))
  act(() => userEvent.click(document.body))

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
