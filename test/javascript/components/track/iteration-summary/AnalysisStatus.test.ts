import React from 'react'
import { render } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { AnalysisStatus } from '../../../../../app/javascript/components/track/iteration-summary/AnalysisStatus'

test('shows Analysing status when analyzerStatus is queued', async () => {
  const { getByText } = render(
    <AnalysisStatus analyzerStatus="queued" representerStatus="approved" />
  )

  expect(getByText('Analysing')).toBeInTheDocument()
})

test('shows Analysing status when representerStatus is queued', async () => {
  const { getByText } = render(
    <AnalysisStatus analyzerStatus="approved" representerStatus="queued" />
  )

  expect(getByText('Analysing')).toBeInTheDocument()
})

test('shows Analysed status when both are not queued', async () => {
  const { getByText } = render(
    <AnalysisStatus analyzerStatus="approved" representerStatus="approved" />
  )

  expect(getByText('Analysed')).toBeInTheDocument()
})
