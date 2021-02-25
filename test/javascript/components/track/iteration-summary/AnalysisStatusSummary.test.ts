import React from 'react'
import { render } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { AnalysisStatusSummary } from '../../../../../app/javascript/components/track/iteration-summary/AnalysisStatusSummary'

/* @kntsoriano - Please can you fix these tests */
/*
test('shows nothing when all zero', async () => {
  const { getByText } = render(
    <AnalysisStatusSummary
  numEssentialAutomatedComments="0"
  numActionableAutomatedComments="0"
  numNonActionableAutomatedComments="0"
    />
  )

  expect(getByText('Essential automated comments')).not.toBeInTheDocument()
  expect(getByText('Recommended automated comments')).not.toBeInTheDocument()
  expect(getByText('Other automated comments')).not.toBeInTheDocument()
})

test('shows counts when comments exist', async () => {
  const { getByText } = render(
    <AnalysisStatusSummary
  numEssentialAutomatedComments="5"
  numActionableAutomatedComments="4"
  numNonActionableAutomatedComments="3"
    />
  )

  expect(getByText('Essential automated comments 5')).not.toBeInTheDocument()
  expect(getByText('Recommended automated comments 4')).not.toBeInTheDocument()
  expect(getByText('Other automated comments 3')).not.toBeInTheDocument()
})
*/

/* @kntsoriano - please delete this */
test('placeholder', async () => {})
