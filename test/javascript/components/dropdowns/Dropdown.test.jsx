import React from 'react'
import { fireEvent, render, screen, waitFor } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { default as Dropdown } from '@/components/dropdowns/Dropdown'
import userEvent from '@testing-library/user-event'
import { awaitPopper } from '../../support/await-popper'

test('button should not be focused on render', async () => {
  const menuButton = {
    label: 'Open menu',
    id: 'menu',
    html: 'Open',
  }
  const menuItems = [{ html: 'Item 1' }, { html: 'Item 2' }]

  render(<Dropdown menuButton={menuButton} menuItems={menuItems} />)
  await awaitPopper()

  expect(screen.getByRole('button', { name: 'Open menu' })).not.toHaveFocus()
})

test('down arrow opens menu on first item', async () => {
  const menuButton = {
    label: 'Open menu',
    html: 'Open',
  }
  const menuItems = [{ html: 'Item 1' }, { html: 'Item 2' }]

  render(<Dropdown menuButton={menuButton} menuItems={menuItems} />)
  await awaitPopper()

  fireEvent.keyDown(screen.getByRole('button'), {
    key: 'ArrowDown',
    code: 'ArrowDown',
  })

  expect(await screen.findByRole('menuitem', { name: 'Item 1' })).toHaveFocus()
})

test('down arrow moves down menu', async () => {
  const menuButton = {
    label: 'Open menu',
    html: 'Open',
  }
  const menuItems = [{ html: 'Item 1' }, { html: 'Item 2' }]

  render(<Dropdown menuButton={menuButton} menuItems={menuItems} />)
  await awaitPopper()

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
    html: 'Open',
  }
  const menuItems = [{ html: 'Item 1' }, { html: 'Item 2' }]

  render(<Dropdown menuButton={menuButton} menuItems={menuItems} />)
  await awaitPopper()

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
    html: 'Open',
  }
  const menuItems = [{ html: 'Item 1' }, { html: 'Item 2' }]

  render(<Dropdown menuButton={menuButton} menuItems={menuItems} />)
  await awaitPopper()

  fireEvent.keyDown(screen.getByRole('button'), {
    key: 'ArrowUp',
    code: 'ArrowUp',
  })

  expect(await screen.findByRole('menuitem', { name: 'Item 2' })).toHaveFocus()
})

test('up arrow moves up menu', async () => {
  const menuButton = {
    label: 'Open menu',
    html: 'Open',
  }
  const menuItems = [{ html: 'Item 1' }, { html: 'Item 2' }]

  render(<Dropdown menuButton={menuButton} menuItems={menuItems} />)
  await awaitPopper()

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
    html: 'Open',
  }
  const menuItems = [{ html: 'Item 1' }, { html: 'Item 2' }]

  render(<Dropdown menuButton={menuButton} menuItems={menuItems} />)
  await awaitPopper()

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
    html: 'Open',
  }
  const menuItems = [{ html: 'Item 1' }, { html: 'Item 2' }]

  render(<Dropdown menuButton={menuButton} menuItems={menuItems} />)
  await awaitPopper()

  userEvent.click(screen.getByRole('button', { name: 'Open menu' }))
  fireEvent.keyDown(screen.getByRole('menuitem', { name: 'Item 1' }), {
    key: 'Tab',
    code: 'Tab',
  })

  await waitFor(() =>
    expect(screen.queryByRole('menu')).not.toBeInTheDocument()
  )
})

test('escape closes menu', async () => {
  const menuButton = {
    label: 'Open menu',
    html: 'Open',
  }
  const menuItems = [{ html: 'Item 1' }, { html: 'Item 2' }]

  render(<Dropdown menuButton={menuButton} menuItems={menuItems} />)
  await awaitPopper()

  userEvent.click(screen.getByRole('button', { name: 'Open menu' }))
  fireEvent.keyDown(screen.getByRole('menuitem', { name: 'Item 1' }), {
    key: 'Escape',
    code: 'Escape',
  })

  await waitFor(() =>
    expect(screen.queryByRole('menu')).not.toBeInTheDocument()
  )
  expect(screen.getByRole('button', { name: 'Open menu' })).toHaveFocus()
})

test('enter closes menu', async () => {
  const menuButton = {
    label: 'Open menu',
    html: 'Open',
  }
  const menuItems = [{ html: 'Item 1' }, { html: 'Item 2' }]

  render(<Dropdown menuButton={menuButton} menuItems={menuItems} />)
  await awaitPopper()

  userEvent.click(screen.getByRole('button', { name: 'Open menu' }))
  fireEvent.keyDown(screen.getByRole('menuitem', { name: 'Item 1' }), {
    key: 'Enter',
    code: 'Enter',
  })

  await waitFor(() =>
    expect(screen.queryByRole('menu')).not.toBeInTheDocument()
  )
  expect(screen.getByRole('button', { name: 'Open menu' })).toHaveFocus()
})

test('space closes menu', async () => {
  const menuButton = {
    label: 'Open menu',
    html: 'Open',
  }
  const menuItems = [{ html: 'Item 1' }, { html: 'Item 2' }]

  render(<Dropdown menuButton={menuButton} menuItems={menuItems} />)
  await awaitPopper()

  userEvent.click(screen.getByRole('button', { name: 'Open menu' }))
  fireEvent.keyDown(screen.getByRole('menuitem', { name: 'Item 1' }), {
    key: ' ',
    code: 'Space',
  })

  await waitFor(() =>
    expect(screen.queryByRole('menu')).not.toBeInTheDocument()
  )
  expect(screen.getByRole('button', { name: 'Open menu' })).toHaveFocus()
})
