import React from 'react'
import { render, screen } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { BugReportModal } from '../../../../app/javascript/components/modals/BugReportModal'
import userEvent from '@testing-library/user-event'
import { TestQueryCache } from '../../support/TestQueryCache'
import { queryClient } from '../../setupTests'

test('form is disabled when URL is not present', async () => {
  render(
    <TestQueryCache queryClient={queryClient}>
      <BugReportModal
        open={true}
        ariaHideApp={false}
        url={null}
        minLength={0}
      />
    </TestQueryCache>
  )

  expect(screen.getByRole('button', { name: /submit/i })).toBeDisabled()
})

test('form is disabled when textarea has not enough characters', async () => {
  render(
    <TestQueryCache queryClient={queryClient}>
      <BugReportModal
        open={true}
        ariaHideApp={false}
        url="https://exercism.test/bug_reports"
        minLength={1}
      />
    </TestQueryCache>
  )

  expect(screen.getByRole('button', { name: /submit/i })).toBeDisabled()
})

test('form is not disabled when textarea has enough characters', async () => {
  render(
    <TestQueryCache queryClient={queryClient}>
      <BugReportModal
        open={true}
        ariaHideApp={false}
        url="https://exercism.test/bug_reports"
        minLength={1}
      />
    </TestQueryCache>
  )

  userEvent.type(screen.getByPlaceholderText(/please/i), 'be')

  expect(
    await screen.findByRole('button', { name: /submit/i })
  ).not.toBeDisabled()
})
