import React from 'react'
import { render } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { BugReportModal } from '../../../../app/javascript/components/modals/BugReportModal'

test('form is disabled when URL is not present', async () => {
  const { getByText } = render(
    <div>
      <BugReportModal open={true} ariaHideApp={false} />
    </div>
  )

  expect(getByText('Submit')).toBeDisabled()
})
