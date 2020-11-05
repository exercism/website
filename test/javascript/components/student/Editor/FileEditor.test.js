import React from 'react'
import { render, fireEvent } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { FileEditor } from '../../../../../app/javascript/components/student/editor/FileEditor'

test('change theme', async () => {
  const { queryByText, getByLabelText } = render(
    <FileEditor file={{ name: 'file', content: '' }} />
  )

  fireEvent.change(getByLabelText('Theme'), { target: { value: 'vs-dark' } })

  expect(queryByText('Theme: vs-dark')).toBeInTheDocument()
})

test('change wrapping', async () => {
  const { queryByText, getByLabelText } = render(
    <FileEditor file={{ name: 'file', content: '' }} />
  )

  fireEvent.change(getByLabelText('Wrap'), { target: { value: 'off' } })

  expect(queryByText('Wrap: off')).toBeInTheDocument()
})

test('apply correct syntax highlighting', async () => {
  const { queryByText } = render(
    <FileEditor file={{ name: 'file', content: '' }} syntaxHighlighter="go" />
  )

  expect(queryByText('Language: go')).toBeInTheDocument()
})
