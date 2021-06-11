import React from 'react'
import { render, screen } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { SizeTag } from '../../../../../../app/javascript/components/contributing/tasks-list/task/SizeTag'

test('renders tag for size = tiny', async () => {
  render(<SizeTag size="tiny" />)

  expect(screen.getByText('xs')).toBeInTheDocument()
})

test('renders tag for size = small', async () => {
  render(<SizeTag size="small" />)

  expect(screen.getByText('s')).toBeInTheDocument()
})

test('renders tag for size = medium', async () => {
  render(<SizeTag size="medium" />)

  expect(screen.getByText('m')).toBeInTheDocument()
})

test('renders tag for size = large', async () => {
  render(<SizeTag size="large" />)

  expect(screen.getByText('l')).toBeInTheDocument()
})

test('renders tag for size = massive', async () => {
  render(<SizeTag size="massive" />)

  expect(screen.getByText('xl')).toBeInTheDocument()
})
