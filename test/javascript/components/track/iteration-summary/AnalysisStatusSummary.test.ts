import React from 'react'
import { render } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { AnalysisStatusSummary } from '../../../../../app/javascript/components/track/iteration-summary/AnalysisStatusSummary'

test('shows Analysing status when analysisStatus is queued', async () => {
  const { getByText } = render(
    <AnalysisStatusSummary
      analysisStatus="queued"
      representationStatus="approved"
    />
  )

  expect(getByText('Analysing')).toBeInTheDocument()
})

test('shows Analysing status when representationStatus is queued', async () => {
  const { getByText } = render(
    <AnalysisStatusSummary
      analysisStatus="approved"
      representationStatus="queued"
    />
  )

  expect(getByText('Analysing')).toBeInTheDocument()
})

test('shows Analysed status when both are not queued', async () => {
  const { getByText } = render(
    <AnalysisStatusSummary
      analysisStatus="approved"
      representationStatus="approved"
    />
  )

  expect(getByText('Automated feedback comments')).toBeInTheDocument()
})
