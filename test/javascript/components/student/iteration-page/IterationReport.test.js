import React from 'react'
import userEvent from '@testing-library/user-event'
import { render, screen, waitFor } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { IterationReport } from '../../../../../app/javascript/components/student/iteration-page/IterationReport'

test('opens and closes accordion', async () => {
  const iteration = {
    idx: 1,
    links: {},
    createdAt: '',
  }

  render(<IterationReport iteration={iteration} track={{}} exercise={{}} />)
  const header = screen.getByRole('button', {
    name: 'View iteration 1 details',
  })
  userEvent.click(header)

  await waitFor(() => {
    expect(header).toHaveAttribute('aria-expanded', 'false')
  })
})
