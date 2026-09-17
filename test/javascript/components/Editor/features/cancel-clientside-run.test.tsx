jest.mock(
  '../../../../../app/javascript/components/editor/FileEditorCodeMirror'
)

// A run that never resolves, so only the abort can end it. Signal captured to assert on later.
let capturedSignal: AbortSignal | undefined

jest.mock(
  '../../../../../app/javascript/components/editor/ClientSideTestRunner/generalTestRunner',
  () => ({
    prefetch: jest.fn(),
    release: jest.fn(),
    runTestsClientSide: jest.fn(({ signal }: { signal?: AbortSignal }) => {
      capturedSignal = signal
      return new Promise(() => {})
    }),
  })
)

import React from 'react'
import { screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { render } from '../../../test-utils'
import '@testing-library/jest-dom/extend-expect'
import Editor from '../../../../../app/javascript/components/Editor'
import { runTestsClientSide } from '../../../../../app/javascript/components/editor/ClientSideTestRunner/generalTestRunner'
import { buildEditor } from './buildEditor'

beforeEach(() => {
  capturedSignal = undefined
})

test('cancelling a client-side run aborts it', async () => {
  render(<Editor {...buildEditor()} experimental={true} />)

  userEvent.click(screen.getByRole('button', { name: 'Run Tests' }))

  // Guards the test: the server path shows the same running state on its own.
  await waitFor(() => expect(runTestsClientSide).toHaveBeenCalledTimes(1))

  // The faux normally hides Cancel; a client-side run is the exception.
  const cancel = await screen.findByRole('button', { name: 'Cancel' })
  expect(capturedSignal?.aborted).toBe(false)

  userEvent.click(cancel)

  // The run is actually stopped, not just hidden behind a cancelled message.
  await waitFor(() => expect(capturedSignal?.aborted).toBe(true))

  localStorage.clear()
})
