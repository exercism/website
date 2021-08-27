jest.mock(
  '../../../../../app/javascript/components/editor/FileEditorCodeMirror'
)

import React from 'react'
import { screen, waitFor } from '@testing-library/react'
import { render } from '../../../test-utils'
import '@testing-library/jest-dom/extend-expect'
import Editor from '../../../../../app/javascript/components/Editor'
import { buildEditor } from './buildEditor'

test('displays introduction', async () => {
  const props = buildEditor({
    overrides: {
      panels: {
        instructions: {
          introduction: 'Ruby is a nice and concise language',
          assignment: { overview: '', generalHints: [], tasks: [] },
        },
      },
    },
  })

  render(<Editor {...props} />)

  expect(
    await screen.findByText('Ruby is a nice and concise language')
  ).toBeInTheDocument()
})

test('does not display introduction if not specified', async () => {
  const props = buildEditor({
    overrides: {
      panels: {
        instructions: {
          assignment: { overview: '', generalHints: [], tasks: [] },
        },
      },
    },
  })

  render(<Editor {...props} />)

  await waitFor(() =>
    expect(screen.queryByText('Introduction')).not.toBeInTheDocument()
  )
})

test('displays introductions overview', async () => {
  const props = buildEditor({
    overrides: {
      panels: {
        instructions: {
          assignment: {
            overview: 'There are a couple of tasks to work on',
            generalHints: [],
            tasks: [],
          },
        },
      },
    },
  })

  render(<Editor {...props} />)

  expect(
    await screen.findByText('There are a couple of tasks to work on')
  ).toBeInTheDocument()
})

test('displays debugging information', async () => {
  const props = buildEditor({
    overrides: {
      panels: {
        instructions: {
          debuggingInstructions: 'There are a couple of tasks to work on',
          assignment: { overview: '', generalHints: [], tasks: [] },
        },
      },
    },
  })

  render(<Editor {...props} />)

  expect(
    await screen.findByText('There are a couple of tasks to work on')
  ).toBeInTheDocument()
})
