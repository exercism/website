import React from 'react'
import { render, screen } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { CategorySummary } from '../../../../app/javascript/components/profile/contributions-summary/CategorySummary'
import { CategoryId } from '../../../../app/javascript/components/profile/ContributionsSummary'

test('prints "No rep" when rep is 0', async () => {
  const category = {
    id: 'building' as CategoryId,
    metric: '0 PRs created',
    reputation: 0,
  }

  render(<CategorySummary category={category} />)

  expect(screen.getByText('No rep')).toBeInTheDocument()
})
