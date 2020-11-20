jest.mock(
  '../../../../../app/javascript/components/student/editor/ExercismMonacoEditor'
)

import React from 'react'
import { render, fireEvent, waitFor } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { FileEditor } from '../../../../../app/javascript/components/student/editor/FileEditor'

test('change theme', async () => {
  const { queryByText, getByLabelText } = render(
    <FileEditor file={{ name: 'file', content: '' }} />
  )

  fireEvent.change(getByLabelText('Theme'), { target: { value: 'vs-dark' } })

  expect(queryByText('Theme: vs-dark')).toBeInTheDocument()

  localStorage.clear()
})

test('change wrapping', async () => {
  const { queryByText, getByLabelText } = render(
    <FileEditor file={{ name: 'file', content: '' }} />
  )

  fireEvent.change(getByLabelText('Wrap'), { target: { value: 'off' } })

  expect(queryByText('Wrap: off')).toBeInTheDocument()

  localStorage.clear()
})

test('apply correct syntax highlighting', async () => {
  const { queryByText } = render(
    <FileEditor file={{ name: 'file', content: '' }} language="go" />
  )

  expect(queryByText('Language: go')).toBeInTheDocument()

  localStorage.clear()
})

test('loads data from storage', async () => {
  localStorage.setItem('file-editor-content', 'class')
  const { queryByText } = render(
    <FileEditor file={{ filename: 'file', content: '' }} language="go" />
  )

  expect(queryByText('Value: class')).toBeInTheDocument()

  localStorage.clear()
})

test('saves data to storage when data changed', async () => {
  jest.useFakeTimers()
  const { getByTestId } = render(
    <FileEditor file={{ filename: 'file', content: '' }} language="go" />
  )

  fireEvent.change(getByTestId('editor-value'), { target: { value: 'code' } })
  await waitFor(() => {
    jest.runOnlyPendingTimers()
  })

  expect(localStorage.getItem('file-editor-content')).toEqual('code')

  localStorage.clear()
})

test('revert to last submission', async () => {
  localStorage.setItem('file-editor-content', 'class')
  const { queryByText } = render(
    <FileEditor file={{ filename: 'file', content: 'file' }} language="go" />
  )

  expect(queryByText('Value: class')).toBeInTheDocument()

  fireEvent.click(queryByText('Revert to last run code'))
  await waitFor(() => {
    jest.runOnlyPendingTimers()
  })

  expect(queryByText('Value: file')).toBeInTheDocument()
  expect(queryByText('Revert to last run code')).not.toBeInTheDocument()

  localStorage.clear()
})
