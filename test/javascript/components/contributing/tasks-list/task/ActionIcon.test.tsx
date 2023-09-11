import React from 'react'
import { render, screen } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { ActionIcon } from '@/components/contributing/tasks-list/task/ActionIcon'

describe('ActionIcon tests', () => {
  test('ActionIcon snapshot', () => {
    const { asFragment } = render(<ActionIcon action="proofread" />)
    expect(asFragment()).toMatchSnapshot()
  })

  test('renders a GraphicalIcon if action is not specified', () => {
    render(<ActionIcon />)

    const img = screen.queryByRole('img')
    expect(img).toBeInTheDocument()

    const altAttribute = img?.getAttribute('alt')
    expect(altAttribute).not.toContain('Action:')
  })

  test('renders an Icon with correct alt tag if action is specified', () => {
    render(<ActionIcon action="create" />)

    const img = screen.queryByRole('img')
    expect(img).toBeInTheDocument()

    const altAttribute = img?.getAttribute('alt')
    expect(altAttribute).toContain('Action: create')
  })
})
