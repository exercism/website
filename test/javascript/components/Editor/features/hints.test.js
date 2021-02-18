jest.mock('../../../../../app/javascript/components/editor/FileEditor')

import React from 'react'
import { render, fireEvent, waitFor } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { Editor } from '../../../../../app/javascript/components/Editor'

test('show hints', async () => {
  const { queryByText } = render(
    <Editor
      files={[{ filename: 'lasagna.rb', content: 'class Lasagna' }]}
      assignment={{
        overview: '',
        generalHints: ['Please use the docs'],
        tasks: [{ title: 'Do complex task', hints: ['Really you should!'] }],
      }}
    />
  )

  fireEvent.click(queryByText('Hints'))

  await waitFor(() => expect(queryByText('General')).toBeInTheDocument())
  await waitFor(() =>
    expect(queryByText('Really you should!')).toBeInTheDocument()
  )
})
