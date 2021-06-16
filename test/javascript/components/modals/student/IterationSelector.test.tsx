import React from 'react'
import { render, screen } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { IterationSelector } from '../../../../../app/javascript/components/modals/student/IterationSelector'
import { createIteration } from '../../../factories/IterationFactory'
import userEvent from '@testing-library/user-event'
import { act } from 'react-dom/test-utils'

test('passing in a null iteration idx selects "All iterations"', async () => {
  render(
    <IterationSelector
      iterations={[createIteration({ idx: 1 })]}
      iterationIdx={null}
      setIterationIdx={jest.fn()}
    />
  )

  expect(screen.getByLabelText('All iterations')).toBeChecked()
  expect(screen.getByLabelText('Single iteration')).not.toBeChecked()
  expect(
    screen.queryByRole('button', { name: /Iteration 1/ })
  ).not.toBeInTheDocument()
})

test('passing in an iteration idx selects "Single iteration"', async () => {
  render(
    <IterationSelector
      iterations={[createIteration({ idx: 1 })]}
      iterationIdx={1}
      setIterationIdx={jest.fn()}
    />
  )

  expect(screen.getByLabelText('Single iteration')).toBeChecked()
  expect(
    screen.getByRole('button', { name: /Iteration 1/ })
  ).toBeInTheDocument()
  expect(screen.getByLabelText('All iterations')).not.toBeChecked()
})

test('selecting "Single iteration" chooses the first iteration in the list', async () => {
  const setIterationIdx = jest.fn()
  const iterations = [createIteration({ idx: 1 }), createIteration({ idx: 2 })]

  render(
    <IterationSelector
      iterations={iterations}
      iterationIdx={null}
      setIterationIdx={setIterationIdx}
    />
  )
  userEvent.click(screen.getByLabelText('Single iteration'))

  expect(setIterationIdx).toHaveBeenCalledWith(1)
})
