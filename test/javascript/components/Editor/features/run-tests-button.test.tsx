jest.mock(
  '../../../../../app/javascript/components/editor/FileEditorCodeMirror'
)

import React from 'react'
import { screen } from '@testing-library/react'
import { render } from '../../../test-utils'
import '@testing-library/jest-dom/extend-expect'
import Editor from '../../../../../app/javascript/components/Editor'
import { buildEditor } from './buildEditor'

test('run tests is enabled if initial submission is null', async () => {
  render(<Editor {...buildEditor()} />)

  expect(screen.getByRole('button', { name: 'Run Tests' })).not.toBeDisabled()

  localStorage.clear()
})
