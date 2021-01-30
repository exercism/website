import React from 'react'
import { fireEvent, render, screen, waitFor } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { PrerenderedDropdown } from '../../../../app/javascript/components/dropdowns/PrerenderedDropdown'
import userEvent from '@testing-library/user-event'

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

test('down arrow moves down menu', async () => {
  const menuButton = {
    label: 'Open menu',
    id: 'menu',
    html: 'Open',
  }
  const menuItems = [{ html: 'Item 1' }, { html: 'Item 2' }]

  render(<PrerenderedDropdown menuButton={menuButton} menuItems={menuItems} />)

  userEvent.click(screen.getByRole('button', { name: 'Open menu' }))
  fireEvent.keyDown(screen.getByRole('menuitem', { name: 'Item 1' }), {
    key: 'ArrowDown',
    code: 'ArrowDown',
  })

  expect(await screen.findByRole('menuitem', { name: 'Item 2' })).toHaveFocus()
})

test('down arrow wraps around menu', async () => {
  const menuButton = {
    label: 'Open menu',
    id: 'menu',
    html: 'Open',
  }
  const menuItems = [{ html: 'Item 1' }, { html: 'Item 2' }]

  render(<PrerenderedDropdown menuButton={menuButton} menuItems={menuItems} />)

  userEvent.click(screen.getByRole('button', { name: 'Open menu' }))
  fireEvent.keyDown(screen.getByRole('menuitem', { name: 'Item 2' }), {
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

test('up arrow moves up menu', async () => {
  const menuButton = {
    label: 'Open menu',
    id: 'menu',
    html: 'Open',
  }
  const menuItems = [{ html: 'Item 1' }, { html: 'Item 2' }]

  render(<PrerenderedDropdown menuButton={menuButton} menuItems={menuItems} />)

  userEvent.click(screen.getByRole('button', { name: 'Open menu' }))
  fireEvent.keyDown(screen.getByRole('menuitem', { name: 'Item 2' }), {
    key: 'ArrowUp',
    code: 'ArrowUp',
  })

  expect(await screen.findByRole('menuitem', { name: 'Item 1' })).toHaveFocus()
})

test('up arrow wraps around menu', async () => {
  const menuButton = {
    label: 'Open menu',
    id: 'menu',
    html: 'Open',
  }
  const menuItems = [{ html: 'Item 1' }, { html: 'Item 2' }]

  render(<PrerenderedDropdown menuButton={menuButton} menuItems={menuItems} />)

  userEvent.click(screen.getByRole('button', { name: 'Open menu' }))
  fireEvent.keyDown(screen.getByRole('menuitem', { name: 'Item 1' }), {
    key: 'ArrowUp',
    code: 'ArrowUp',
  })

  expect(await screen.findByRole('menuitem', { name: 'Item 2' })).toHaveFocus()
})

test('tab closes menu', async () => {
  const menuButton = {
    label: 'Open menu',
    id: 'menu',
    html: 'Open',
  }
  const menuItems = [{ html: 'Item 1' }, { html: 'Item 2' }]

  render(<PrerenderedDropdown menuButton={menuButton} menuItems={menuItems} />)

  userEvent.click(screen.getByRole('button', { name: 'Open menu' }))
  fireEvent.keyDown(screen.getByRole('menuitem', { name: 'Item 1' }), {
    key: 'Tab',
    code: 'Tab',
  })

  await waitFor(() =>
    expect(screen.queryByRole('menu')).not.toBeInTheDocument()
  )
})
