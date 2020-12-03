import React from 'react'
import { render, fireEvent, waitFor } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { Settings } from '../../../../../app/javascript/components/editor/header/Settings'

test('toggles settings panel when clicking on button', async () => {
  const { getByTitle, queryByLabelText } = render(<Settings />)

  fireEvent.click(getByTitle('Settings'))

  await waitFor(() => expect(queryByLabelText('Theme')).toBeInTheDocument())

  fireEvent.click(getByTitle('Settings'))

  await waitFor(() => expect(queryByLabelText('Theme')).not.toBeInTheDocument())
})

test('hides settings panel when clicking outside the component', async () => {
  const { getByTitle, queryByLabelText } = render(<Settings />)

  fireEvent.click(getByTitle('Settings'))
  await waitFor(() => expect(queryByLabelText('Theme')).toBeInTheDocument())

  fireEvent.click(document)
  await waitFor(() => expect(queryByLabelText('Theme')).not.toBeInTheDocument())
})
