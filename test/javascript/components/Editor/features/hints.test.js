jest.mock('../../../../../app/javascript/components/editor/FileEditorAce')

import React from 'react'
import { render, fireEvent, waitFor, screen } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { Editor } from '../../../../../app/javascript/components/Editor'

test('show hints', async () => {
  render(
    <Editor
      files={[{ filename: 'lasagna.rb', content: 'class Lasagna' }]}
      assignment={{
        overview: '',
        generalHints: ['Please use the docs'],
        tasks: [{ title: 'Do complex task', hints: ['Really you should!'] }],
      }}
    />
  )

  fireEvent.click(await screen.findByAltText('View all hints'))

  expect(await screen.findByText('General')).toBeInTheDocument()
  expect(await screen.findByText('Really you should!')).toBeInTheDocument()
})
