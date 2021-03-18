jest.mock('../../../../../app/javascript/components/editor/FileEditor')

import React from 'react'
import { render, fireEvent, waitFor, screen } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { Editor } from '../../../../../app/javascript/components/Editor'

test('toggle command palette when clicking on button', async () => {
  render(
    <Editor
      files={[{ filename: 'file', content: 'file' }]}
      assignment={{ overview: '', generalHints: [], tasks: [] }}
    />
  )

  fireEvent.click(screen.getByAltText('Keyboard Shortcuts'))
  await waitFor(() =>
    expect(screen.queryByText('Palette open: true')).toBeInTheDocument()
  )

  localStorage.clear()
})
