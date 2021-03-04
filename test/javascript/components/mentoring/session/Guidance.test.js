import React from 'react'
import userEvent from '@testing-library/user-event'
import { waitFor, render, screen } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { Guidance } from '../../../../../app/javascript/components/mentoring/session/Guidance'

test('how you solved the exercise is open by default', async () => {
  render(<Guidance />)

  expect(
    screen.getByRole('group', { name: 'Collapsable mentor notes' })
  ).toHaveAttribute('open')
  expect(
    screen.getByRole('group', {
      name: 'Collapsable information on automated feedback',
    })
  ).not.toHaveAttribute('open')
})

test('open and close same accordion', async () => {
  render(<Guidance />)

  userEvent.click(
    screen.getByRole('group', { name: 'Collapsable mentor notes' })
  )

  waitFor(() => {
    expect(
      screen.getdByRole('group', { name: 'Collapsable mentor notes' })
    ).not.toHaveAttribute('open')
  })
})

test('only one accordion is open at a time', async () => {
  render(<Guidance />)

  userEvent.click(
    screen.getByRole('group', {
      name: 'Collapsable information on automated feedback',
    })
  )

  waitFor(() => {
    expect(
      screen.getByRole('group', { name: 'Collapsable mentor notes' })
    ).not.toHaveAttribute('open')
    expect(
      screen.getByRole('group', {
        name: 'Collapsable information on automated feedback',
      })
    ).toHaveAttribute('open')
  })
})

test('displays notes', async () => {
  const notes = '<h2>Notes</h2>'
  render(<Guidance notes={notes} />)

  expect(screen.getByRole('heading', { name: 'Notes' })).toBeInTheDocument()
})

test('hides how you solved the solution if mentor solution is null', async () => {
  const notes = '<h2>Notes</h2>'
  render(<Guidance notes={notes} />)

  expect(
    screen.queryByRole('group', { name: 'How you solved the exercise' })
  ).not.toBeInTheDocument()
})
