jest.mock(
  '../../../../../app/javascript/components/editor/FileEditorCodeMirror'
)

// A client-side run that never finishes. The point of the test is what the
// results panel shows *while* the run is in flight, so the run must not
// resolve on its own.
jest.mock(
  '../../../../../app/javascript/components/editor/ClientSideTestRunner/generalTestRunner',
  () => ({
    prefetch: jest.fn(),
    release: jest.fn(),
    runTestsClientSide: jest.fn(() => new Promise(() => {})),
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

test('the results panel shows a run in progress as soon as tests are run client-side', async () => {
  // Not via buildEditor's overrides: test-data-bot only applies those to keys
  // the builder declares, and it doesn't declare this one.
  render(<Editor {...buildEditor()} experimental={true} />)

  expect(screen.queryByRole('status')).not.toBeInTheDocument()

  userEvent.click(screen.getByRole('button', { name: 'Run Tests' }))

  // Before createSubmission has been called, and long before the run has
  // finished, the panel is already in its "Running tests" state.
  await waitFor(() => expect(screen.getByRole('status')).toBeInTheDocument())

  // Guards the test itself: this only means anything if the client-side path
  // was the one taken. On the server path the mutation shows the same state
  // on its own, and the assertion above would pass for the wrong reason.
  await waitFor(() => expect(runTestsClientSide).toHaveBeenCalledTimes(1))

  localStorage.clear()
})
