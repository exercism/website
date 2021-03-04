import React from 'react'
import { act, waitFor, render, screen } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import userEvent from '@testing-library/user-event'
import { Details } from '../../../../app/javascript/components/common/Details'

test('closed details', () => {
  render(
    <Details isOpen={false}>
      <Details.Summary>Header</Details.Summary>
      <p>Content</p>
    </Details>
  )

  expect(screen.getByRole('group')).not.toHaveAttribute('open')
  expect(screen.queryByText('Content')).not.toBeVisible()
})

test('open details', () => {
  render(
    <Details isOpen={true}>
      <Details.Summary>Header</Details.Summary>
      <p>Content</p>
    </Details>
  )

  expect(screen.getByRole('group')).toHaveAttribute('open')
  expect(screen.queryByText('Content')).toBeVisible()
})

test('clicking on header opens and closes', () => {
  render(
    <Details isOpen={true}>
      <Details.Summary>Header</Details.Summary>
      <p>Content</p>
    </Details>
  )

  expect(screen.getByRole('group')).toHaveAttribute('open')
  expect(screen.queryByText('Content')).toBeVisible()

  act(() => {
    userEvent.click(screen.getByRole('group'))
  })

  waitFor(() => {
    expect(screen.getByRole('group')).not.toHaveAttribute('open')
    expect(screen.queryByText('Content')).not.toBeVisible()
  })

  act(() => {
    userEvent.click(screen.getByRole('group'))
  })

  waitFor(() => {
    expect(screen.getByRole('group')).toHaveAttribute('open')
    expect(screen.queryByText('Content')).toBeVisible()
  })
})
