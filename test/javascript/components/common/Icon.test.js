import React from 'react'
import { render, waitFor } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { Icon } from '../../../../app/javascript/components/common/Icon'

test('icon renders correctly', async () => {
  const { queryByTitle, queryByRole } = render(
    <Icon icon="reputation" alt="Reputation" />
  )

  await waitFor(() => expect(queryByRole('img')).toBeInTheDocument())
  await waitFor(() => expect(queryByTitle('Reputation')).toBeInTheDocument())
})
