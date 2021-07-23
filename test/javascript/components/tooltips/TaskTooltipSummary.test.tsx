import React from 'react'
import { render, screen } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { SummaryDetails } from '../../../../app/javascript/components/tooltips/task-tooltip/Summary'

function expectTestSummary(task, expected) {
  render(<SummaryDetails task={task} />)
  expect(screen.getByText(expected)).toBeInTheDocument()
}

test('no tags', async () => {
  const task = { tags: {} }
  const expected = 'For this task you will be working on Exercism changes.'
  expectTestSummary(task, expected)
})

test('action', async () => {
  const task = { tags: { action: 'create' } }
  const expected = 'For this task you will be creating Exercism changes.'
  expectTestSummary(task, expected)
})

test('module', async () => {
  const task = { tags: { module: 'test-runner' } }
  const expected = 'For this task you will be working on Test Runner changes.'
  expectTestSummary(task, expected)
})

test('type', async () => {
  const task = { tags: { type: 'docs' } }
  const expected = 'For this task you will be working on Exercism docs.'
  expectTestSummary(task, expected)
})

test('track', async () => {
  const task = { tags: {}, track: { title: 'Ruby' } }
  const expected =
    'For this task you will be working on Exercism changes for the Ruby Track.'
  expectTestSummary(task, expected)
})

test('everything', async () => {
  const task = {
    tags: {
      action: 'fix',
      module: 'concept-exercise',
    },
    track: { title: 'JavaScript' },
  }
  const expected =
    'For this task you will be fixing Learning Exercise changes for the JavaScript Track.'
  expectTestSummary(task, expected)
})
