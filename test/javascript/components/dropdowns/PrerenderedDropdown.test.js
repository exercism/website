import React from 'react'
import { fireEvent, render, screen } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { PrerenderedDropdown } from '../../../../app/javascript/components/dropdowns/PrerenderedDropdown'

test('down arrow opens menu on first item', async () => {
  const menuButton = {
    label: 'Open menu',
    id: 'menu',
    html: 'Open',
  }
  const menuItems = [{ html: 'Item 1' }, { html: 'Item 2' }]

  render(<PrerenderedDropdown menuButton={menuButton} menuItems={menuItems} />)

  fireEvent.keyDown(screen.getByRole('button'), {
    key: 'ArrowDown',
    code: 'ArrowDown',
  })

  expect(await screen.findByRole('menuitem', { name: 'Item 1' })).toHaveFocus()
})

test('up arrow opens menu on last item', async () => {
  const menuButton = {
    label: 'Open menu',
    id: 'menu',
    html: 'Open',
  }
  const menuItems = [{ html: 'Item 1' }, { html: 'Item 2' }]

  render(<PrerenderedDropdown menuButton={menuButton} menuItems={menuItems} />)

  fireEvent.keyDown(screen.getByRole('button'), {
    key: 'ArrowUp',
    code: 'ArrowUp',
  })

  expect(await screen.findByRole('menuitem', { name: 'Item 2' })).toHaveFocus()
})
