jest.mock(
  '../../../../../app/javascript/components/student/editor/ExercismMonacoEditor'
)

import React from 'react'
import { render, fireEvent, waitFor } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { FileEditor } from '../../../../../app/javascript/components/student/editor/FileEditor'
import localForage from 'localforage'

test('change theme', async () => {
  const { queryByText, getByLabelText } = render(
    <FileEditor file={{ name: 'file', content: '' }} />
  )

  fireEvent.change(getByLabelText('Theme'), { target: { value: 'vs-dark' } })

  await waitFor(() => expect(queryByText('Theme: vs-dark')).toBeInTheDocument())

  await localForage.clear()
})

test('change wrapping', async () => {
  const { queryByText, getByLabelText } = render(
    <FileEditor file={{ name: 'file', content: '' }} />
  )

  fireEvent.change(getByLabelText('Wrap'), { target: { value: 'off' } })

  await waitFor(() => expect(queryByText('Wrap: off')).toBeInTheDocument())

  await localForage.clear()
})

test('apply correct syntax highlighting', async () => {
  const { queryByText } = render(
    <FileEditor file={{ name: 'file', content: '' }} language="go" />
  )

  await waitFor(() => expect(queryByText('Language: go')).toBeInTheDocument())

  await localForage.clear()
})

test('loads data from storage', async () => {
  await localForage.setItem('file-editor-content', 'class')
  const { queryByText } = render(
    <FileEditor file={{ filename: 'file', content: '' }} language="go" />
  )

  await waitFor(() => expect(queryByText('Value: class')).toBeInTheDocument())

  await localForage.clear()
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

  expect(await localForage.getItem('file-editor-content')).toEqual('code')

  await localForage.clear()
})

test('revert to last submission', async () => {
  await localForage.setItem('file-editor-content', 'class')
  const { queryByText } = render(
    <FileEditor file={{ filename: 'file', content: 'file' }} language="go" />
  )

  await waitFor(() => expect(queryByText('Value: class')).toBeInTheDocument())

  fireEvent.click(queryByText('Revert to last run code'))

  await waitFor(() => expect(queryByText('Value: file')).toBeInTheDocument())
  await waitFor(() =>
    expect(queryByText('Revert to last run code')).not.toBeInTheDocument()
  )

  await localForage.clear()
})
