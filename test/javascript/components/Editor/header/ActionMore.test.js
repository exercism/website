import React from 'react'
import { render, fireEvent, waitFor } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { ActionMore } from '../../../../../app/javascript/components/editor/header/ActionMore'

test('hides panel after clicking on revert button', async () => {
  const onRevert = () => {}
  const { getByTitle, getByText, queryByText } = render(
    <ActionMore onRevertToLastIteration={onRevert} />
  )

  fireEvent.click(getByTitle('Open more options'))
  fireEvent.click(getByText('Revert to last iteration submission'))

  await waitFor(() => {
    expect(
      queryByText('Revert to last iteration submission')
    ).not.toBeInTheDocument()
  })
})
