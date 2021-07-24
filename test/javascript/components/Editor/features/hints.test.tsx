jest.mock(
  '../../../../../app/javascript/components/editor/FileEditorCodeMirror'
)

import React from 'react'
import { screen } from '@testing-library/react'
import { render } from '../../../test-utils'
import '@testing-library/jest-dom/extend-expect'
import { Editor } from '../../../../../app/javascript/components/Editor'
import { buildEditor } from './buildEditor'
import userEvent from '@testing-library/user-event'

test('show hints', async () => {
  const props = buildEditor({
    overrides: {
      panels: {
        instructions: {
          assignment: {
            overview: '',
            generalHints: ['Please use the docs'],
            tasks: [
              { title: 'Do complex task', hints: ['Really you should!'] },
            ],
          },
        },
      },
    },
  })

  render(<Editor {...props} />)

  userEvent.click(await screen.findByAltText('View all hints'))

  expect(await screen.findByText('General')).toBeInTheDocument()
  expect(await screen.findByText('Really you should!')).toBeInTheDocument()
})
