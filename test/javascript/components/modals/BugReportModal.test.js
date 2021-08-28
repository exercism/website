import React from 'react'
import { render, screen } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { BugReportModal } from '../../../../app/javascript/components/modals/BugReportModal'

test('form is disabled when URL is not present', async () => {
  render(
    <div>
      <BugReportModal open={true} ariaHideApp={false} />
    </div>
  )

  expect(screen.getByRole('button', { name: /submit/i })).toBeDisabled()
})
