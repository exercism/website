import React from 'react'
import userEvent from '@testing-library/user-event'
import { act, render, screen, waitFor } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { IterationReport } from '../../../../../app/javascript/components/student/iteration-page/IterationReport'

test('opens and closes detail blocks', async () => {
  const iteration = {
    idx: 1,
    links: {},
    createdAt: '',
  }

  render(
    <IterationReport
      isOpen={false}
      iteration={iteration}
      track={{}}
      exercise={{}}
      onExpanded={() => {}}
      onCompressed={() => {}}
    />
  )
  const details = screen.getByRole('group')
  const summary = screen.getByRole('button')

  act(() => {
    userEvent.click(summary)
  })

  await waitFor(() => {
    expect(details).toHaveAttribute('open')
  })
})
