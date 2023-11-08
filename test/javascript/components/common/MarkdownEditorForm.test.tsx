import React from 'react'
import { render } from '../../test-utils'
import { waitFor, screen } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { MarkdownEditorForm } from '../../../../app/javascript/components/common/MarkdownEditorForm'
import { expectConsoleError } from '../../support/silence-console'
import { stubRange } from '../../support/code-mirror-helpers'
import { QueryStatus } from '@tanstack/react-query'
import userEvent from '@testing-library/user-event'

stubRange()

test('hides footer when form is compressed', async () => {
  render(
    <MarkdownEditorForm
      expanded={false}
      onSubmit={jest.fn()}
      onCancel={jest.fn()}
      onChange={jest.fn()}
      value=""
      error={null}
      status={'loading' as QueryStatus}
      defaultError={new Error()}
      action="new"
    />
  )

  await waitFor(() =>
    expect(
      screen.queryByRole('button', { name: /Send/ })
    ).not.toBeInTheDocument()
  )
})

test('shows error messages', async () => {
  await expectConsoleError(async () => {
    render(
      <MarkdownEditorForm
        expanded={false}
        onSubmit={jest.fn()}
        onCancel={jest.fn()}
        onChange={jest.fn()}
        value=""
        error={new Error()}
        status={'error' as QueryStatus}
        defaultError={new Error('Unable to save')}
        action="new"
      />
    )

    expect(await screen.findByText('Unable to save')).toBeInTheDocument()
  })
})

test('focuses text editor when expanded', async () => {
  render(
    <MarkdownEditorForm
      expanded
      onSubmit={jest.fn()}
      onCancel={jest.fn()}
      onChange={jest.fn()}
      value=""
      error={null}
      status={'success' as QueryStatus}
      defaultError={new Error()}
      action="new"
    />
  )

  await screen.findByTestId('markdown-editor')

  const editor = document.querySelector('.CodeMirror')
  expect(editor).toHaveAttribute(
    'class',
    'CodeMirror cm-s-easymde CodeMirror-wrap CodeMirror-focused'
  )
})

test('does not focus text editor compressed', async () => {
  render(
    <MarkdownEditorForm
      expanded={false}
      onSubmit={jest.fn()}
      onCancel={jest.fn()}
      onChange={jest.fn()}
      value=""
      error={null}
      status={'success' as QueryStatus}
      defaultError={new Error()}
      action="new"
    />
  )

  userEvent.click(await screen.findByTestId('markdown-editor'))

  const editor = document.querySelector('.CodeMirror')
  expect(editor).toHaveAttribute(
    'class',
    'CodeMirror cm-s-easymde CodeMirror-wrap'
  )
})
