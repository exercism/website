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
    <FileEditor file={{ name: 'file', content: '' }} language="go" />
  )

  expect(queryByText('Language: go')).toBeInTheDocument()
})

test('loads data from localstorage', async () => {
  localStorage.setItem('file-editor-content', 'class')
  const { queryByText } = render(
    <FileEditor file={{ name: 'file', content: '' }} language="go" />
  )

  expect(queryByText('Value: class')).toBeInTheDocument()

  localStorage.clear()
})

test('save data to when data changed', async () => {
  const { getByTestId } = render(
    <FileEditor file={{ name: 'file', content: '' }} language="go" />
  )

  fireEvent.change(getByTestId('editor-value'), { target: { value: 'code' } })

  expect(localStorage.getItem('file-editor-content')).toEqual('code')

  localStorage.clear()
})

test('revert to last submission', async () => {
  localStorage.setItem('file-editor-content', 'class')
  const { queryByText } = render(
    <FileEditor file={{ name: 'file', content: 'file' }} language="go" />
  )

  fireEvent.click(queryByText('Revert to last run code'))

  expect(queryByText('Value: file')).toBeInTheDocument()
  expect(queryByText('Revert to last run code')).not.toBeInTheDocument()

  localStorage.clear()
})
