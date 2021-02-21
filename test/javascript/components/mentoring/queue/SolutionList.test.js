import React from 'react'
import { render, screen, waitFor } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { SolutionList } from '../../../../../app/javascript/components/mentoring/queue/SolutionList'

test('hides pagination when totalPages < 1', async () => {
  const data = {
    results: [],
    meta: {
      totalPages: 1,
    },
  }

  render(
    <SolutionList status="success" latestData={data} resolvedData={data} />
  )

  await waitFor(() =>
    expect(
      screen.queryByRole('button', { name: 'Go to first page' })
    ).not.toBeInTheDocument()
  )
})
