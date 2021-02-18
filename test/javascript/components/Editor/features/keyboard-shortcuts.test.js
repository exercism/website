jest.mock('../../../../../app/javascript/components/editor/FileEditor')

import React from 'react'
import { render, fireEvent, waitFor } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { Editor } from '../../../../../app/javascript/components/Editor'

test('toggle command palette when clicking on button', async () => {
  const { getByTitle, queryByText } = render(
    <Editor
      files={[{ filename: 'file', content: 'file' }]}
      assignment={{ overview: '', generalHints: [], tasks: [] }}
    />
  )

  fireEvent.click(getByTitle('Keyboard Shortcuts'))
  await waitFor(() =>
    expect(queryByText('Palette open: true')).toBeInTheDocument()
  )

  localStorage.clear()
})
