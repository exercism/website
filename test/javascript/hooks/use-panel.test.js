import React from 'react'
import { render, fireEvent, waitFor } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { usePanel } from '../../../app/javascript/hooks/use-panel'

const TestComponent = () => {
  const {
    open,
    setOpen,
    setButtonElement,
    setPanelElement,
    styles,
    attributes,
  } = usePanel()

  return (
    <React.Fragment>
      <button
        ref={setButtonElement}
        onClick={() => {
          setOpen(!open)
        }}
      >
        Open panel
      </button>
      <div ref={setPanelElement} style={styles.popper} {...attributes.popper}>
        {open ? <div>Opened</div> : null}
      </div>
    </React.Fragment>
  )
}

test('toggles panel open when clicking on button', async () => {
  const { getByText, queryByText } = render(<TestComponent />)

  fireEvent.click(getByText('Open panel'))
  await waitFor(() => expect(queryByText('Opened')).toBeInTheDocument())

  fireEvent.click(getByText('Open panel'))
  await waitFor(() => expect(queryByText('Opened')).not.toBeInTheDocument())
})

test('hides panel when clicking outside component', async () => {
  const { getByText, queryByText } = render(<TestComponent />)

  fireEvent.click(getByText('Open panel'))
  await waitFor(() => expect(queryByText('Opened')).toBeInTheDocument())

  fireEvent.click(document)
  await waitFor(() => expect(queryByText('Opened')).not.toBeInTheDocument())
})
