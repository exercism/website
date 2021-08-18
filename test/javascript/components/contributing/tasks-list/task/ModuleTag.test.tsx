import React from 'react'
import { render, screen } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { ModuleTag } from '../../../../../../app/javascript/components/contributing/tasks-list/task/ModuleTag'

test('renders tag for module = analyzer', async () => {
  render(<ModuleTag module="analyzer" />)

  expect(screen.getByRole('img', { name: 'Analyzer' })).toBeInTheDocument()
})

test('renders tag for module = representer', async () => {
  render(<ModuleTag module="representer" />)

  expect(screen.getByRole('img', { name: 'Representer' })).toBeInTheDocument()
})

test('renders tag for module = concept-exercise', async () => {
  render(<ModuleTag module="concept-exercise" />)

  expect(
    screen.getByRole('img', { name: 'Learning Exercise' })
  ).toBeInTheDocument()
})

test('renders tag for module = practice-exercise', async () => {
  render(<ModuleTag module="practice-exercise" />)

  expect(
    screen.getByRole('img', { name: 'Practice Exercise' })
  ).toBeInTheDocument()
})

test('renders tag for module = test-runner', async () => {
  render(<ModuleTag module="test-runner" />)

  expect(screen.getByRole('img', { name: 'Test Runner' })).toBeInTheDocument()
})

test('renders tag for module = generator', async () => {
  render(<ModuleTag module="generator" />)

  expect(
    screen.getByRole('img', { name: 'Track Generators' })
  ).toBeInTheDocument()
})

test('renders tag for module = concept', async () => {
  render(<ModuleTag module="concept" />)

  expect(
    screen.getByRole('img', { name: 'Track Concepts' })
  ).toBeInTheDocument()
})
