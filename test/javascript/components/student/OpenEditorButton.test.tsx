import React from 'react'
import { render, screen } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { OpenEditorButton } from '../../../../app/javascript/components/student/OpenEditorButton'

test('disabled when status is locked', async () => {
  const { container } = render(
    <OpenEditorButton command="command" status="locked" links={null} />
  )

  expect(container.firstChild).toHaveAttribute(
    'class',
    'c-combo-button --disabled'
  )
  expect(screen.getByText('Open editor')).toBeInTheDocument()
})

test('shows button to start exercise when available', async () => {
  render(
    <OpenEditorButton
      command="command"
      status="available"
      links={{ start: '' }}
    />
  )

  expect(
    screen.getByRole('button', { name: 'Start in editor' })
  ).toBeInTheDocument()
})

test('shows link to exercise when completed', async () => {
  render(
    <OpenEditorButton
      status="completed"
      command="command"
      links={{ exercise: 'https://exercism.test/exercise' }}
    />
  )

  expect(screen.getByRole('link', { name: 'Open editor' })).toHaveAttribute(
    'href',
    'https://exercism.test/exercise'
  )
})

test('shows link to exercise when published', async () => {
  render(
    <OpenEditorButton
      status="published"
      command="command"
      links={{ exercise: 'https://exercism.test/exercise' }}
    />
  )

  expect(screen.getByRole('link', { name: 'Open editor' })).toHaveAttribute(
    'href',
    'https://exercism.test/exercise'
  )
})

test('shows link to exercise when other status', async () => {
  render(
    <OpenEditorButton
      status="iterated"
      command="command"
      links={{ exercise: 'https://exercism.test/exercise' }}
    />
  )

  expect(
    screen.getByRole('link', { name: 'Continue in editor' })
  ).toHaveAttribute('href', 'https://exercism.test/exercise')
})
