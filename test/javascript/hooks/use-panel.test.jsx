import React from 'react'
import { render, screen, act, waitFor } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { usePanel } from '../../../app/javascript/hooks/use-panel'
import userEvent from '@testing-library/user-event'

const TestComponent = () => {
  const { open, setOpen, buttonAttributes, panelAttributes } = usePanel()

  return (
    <React.Fragment>
      <button onClick={() => setOpen(!open)} {...buttonAttributes}>
        Open panel
      </button>
      {open ? (
        <div {...panelAttributes}>
          <div>Opened</div>
        </div>
      ) : null}
    </React.Fragment>
  )
}

test('toggles panel open when clicking on button', async () => {
  render(<TestComponent />)

  userEvent.click(screen.getByRole('button', { name: 'Open panel' }))
  expect(await screen.findByText('Opened')).toBeInTheDocument()

  userEvent.click(screen.getByRole('button', { name: 'Open panel' }))
  await waitFor(() =>
    expect(screen.queryByText('Opened')).not.toBeInTheDocument()
  )
})

test('hides panel when clicking outside component', async () => {
  render(<TestComponent />)

  userEvent.click(screen.getByRole('button', { name: 'Open panel' }))
  const panel = await screen.findByText('Opened')
  act(() => {
    userEvent.click(document.body)
  })
  expect(panel).not.toBeInTheDocument()
})
