jest.mock(
  '../../../../../app/javascript/components/editor/FileEditorCodeMirror'
)

import React from 'react'
import { waitFor, screen, act } from '@testing-library/react'
import { render } from '../../../test-utils'
import '@testing-library/jest-dom/extend-expect'
import Editor from '../../../../../app/javascript/components/Editor'
import { buildEditor } from './buildEditor'
import userEvent from '@testing-library/user-event'

test('change theme', async () => {
  render(<Editor {...buildEditor()} />)

  userEvent.click(screen.getByAltText('Settings'))
  userEvent.click(screen.getByLabelText('Dark'))

  await waitFor(() => {
    expect(screen.queryByText('Theme: material-ocean')).toBeInTheDocument()
  })
})

test('change keybindings', async () => {
  render(<Editor {...buildEditor()} />)

  userEvent.click(screen.getByAltText('Settings'))
  userEvent.click(await screen.findByLabelText('Vim'))
  act(() => userEvent.click(document.body))

  await waitFor(() => {
    expect(screen.getByText('Keybindings: vim')).toBeInTheDocument()
  })
})

test('change wrapping', async () => {
  render(<Editor {...buildEditor()} />)

  userEvent.click(screen.getByAltText('Settings'))
  userEvent.click(screen.getAllByLabelText('Off')[0])

  await waitFor(() => {
    expect(screen.queryByText('Wrap: off')).toBeInTheDocument()
  })
})

test('change "Tab mode"', async () => {
  render(<Editor {...buildEditor()} />)

  userEvent.click(screen.getByAltText('Settings'))
  userEvent.click(screen.getAllByLabelText('Editor')[0])

  await waitFor(() => {
    expect(screen.queryByText('Tab behavior: captured')).toBeInTheDocument()
  })
})
