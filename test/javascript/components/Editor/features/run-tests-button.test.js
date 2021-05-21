jest.mock('../../../../../app/javascript/components/editor/FileEditorAce')

import React from 'react'
import { render, fireEvent, waitFor, screen } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { Editor } from '../../../../../app/javascript/components/Editor'

test('run tests is enabled if initial submission is null', async () => {
  render(
    <Editor
      initialSubmission={null}
      files={[{ filename: 'file', content: 'file' }]}
      assignment={{ overview: '', generalHints: [], tasks: [] }}
    />
  )

  expect(
    screen.getByRole('button', { name: 'Run Tests F2' })
  ).not.toBeDisabled()

  localStorage.clear()
})
