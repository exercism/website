import React from 'react'
import { render, screen } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { default as OpenEditorButton } from '@/components/student/OpenEditorButton'
import userEvent from '@testing-library/user-event'
import { TestQueryCache } from '../../support/TestQueryCache'
import { queryClient } from '../../setupTests'

test('disabled when status is locked', async () => {
  const { container } = render(
    <TestQueryCache queryClient={queryClient}>
      <OpenEditorButton
        command="command"
        status="locked"
        editorEnabled
        links={{ local: 'https://exercism.test/solving-locally ' }}
      />
    </TestQueryCache>
  )

  expect(container.firstChild).toHaveAttribute(
    'class',
    'c-combo-button --disabled '
  )
  expect(screen.getByText('Open in editor')).toBeInTheDocument()
})

test('shows button to start exercise when available', async () => {
  render(
    <TestQueryCache queryClient={queryClient}>
      <OpenEditorButton
        command="command"
        status="available"
        editorEnabled
        links={{ start: '', local: 'https://exercism.test/solving-locally' }}
      />
    </TestQueryCache>
  )

  expect(
    screen.getByRole('button', { name: 'Start in editor' })
  ).toBeInTheDocument()
})

test('shows link to exercise when completed', async () => {
  render(
    <TestQueryCache queryClient={queryClient}>
      <OpenEditorButton
        status="completed"
        command="command"
        editorEnabled
        links={{
          exercise: 'https://exercism.test/exercise',
          local: 'https://exercism.test/solving-locally',
        }}
      />
    </TestQueryCache>
  )

  expect(screen.getByRole('link', { name: 'Open in editor' })).toHaveAttribute(
    'href',
    'https://exercism.test/exercise'
  )
})

test('shows link to exercise when published', async () => {
  render(
    <TestQueryCache queryClient={queryClient}>
      <OpenEditorButton
        status="published"
        command="command"
        editorEnabled
        links={{
          exercise: 'https://exercism.test/exercise',
          local: 'https://exercism.test/solving-locally',
        }}
      />
    </TestQueryCache>
  )

  expect(screen.getByRole('link', { name: 'Open in editor' })).toHaveAttribute(
    'href',
    'https://exercism.test/exercise'
  )
})

test('shows link to exercise when other status', async () => {
  render(
    <TestQueryCache queryClient={queryClient}>
      <OpenEditorButton
        status="iterated"
        command="command"
        editorEnabled
        links={{
          exercise: 'https://exercism.test/exercise',
          local: 'https://exercism.test/solving-locally',
        }}
      />
    </TestQueryCache>
  )

  expect(
    screen.getByRole('link', { name: 'Continue in editor' })
  ).toHaveAttribute('href', 'https://exercism.test/exercise')
})

test('disables primary button when editor is disabled', async () => {
  render(
    <TestQueryCache queryClient={queryClient}>
      <OpenEditorButton
        status="iterated"
        command="command"
        editorEnabled={false}
        links={{
          exercise: 'https://exercism.test/exercise',
          local: 'https://exercism.test/solving-locally',
        }}
      />
    </TestQueryCache>
  )

  expect(
    screen.getByRole('button', { name: 'Continue in editor' })
  ).toHaveClass('--disabled')
})
