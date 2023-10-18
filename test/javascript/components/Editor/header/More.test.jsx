import React from 'react'
import { render, fireEvent, waitFor, screen } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { ActionMore } from '../../../../../app/javascript/components/editor/header/ActionMore'
import { TestQueryCache } from '../../../support/TestQueryCache'
import { queryClient } from '../../../setupTests'

test('hides panel after clicking on revert button', async () => {
  const onRevert = () => null
  render(
    <TestQueryCache queryClient={queryClient}>
      <ActionMore onRevertToLastIteration={onRevert} />
    </TestQueryCache>
  )

  fireEvent.click(screen.getByAltText('Open more options'))
  fireEvent.click(screen.getByText('Revert to last iteration'))

  await waitFor(() => {
    expect(
      screen.queryByText('Revert to last iteration')
    ).not.toBeInTheDocument()
  })
})
