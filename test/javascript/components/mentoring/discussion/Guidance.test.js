import React from 'react'
import userEvent from '@testing-library/user-event'
import { render, screen } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { Guidance } from '../../../../../app/javascript/components/mentoring/discussion/Guidance'

test('how you solved the exercise is open by default', async () => {
  render(<Guidance />)

  expect(screen.getByRole('button', { name: 'Mentor notes' })).toHaveAttribute(
    'aria-expanded',
    'true'
  )
  expect(
    screen.getByRole('button', { name: 'Automated feedback' })
  ).toHaveAttribute('aria-expanded', 'false')
})

test('open and close same accordion', async () => {
  render(<Guidance />)

  userEvent.click(screen.getByRole('button', { name: 'Mentor notes' }))

  expect(
    await screen.findByRole('button', { name: 'Mentor notes' })
  ).toHaveAttribute('aria-expanded', 'false')
})

test('only one accordion is open at a time', async () => {
  render(<Guidance />)

  userEvent.click(screen.getByRole('button', { name: 'Automated feedback' }))

  expect(screen.getByRole('button', { name: 'Mentor notes' })).toHaveAttribute(
    'aria-expanded',
    'false'
  )
  expect(
    screen.getByRole('button', { name: 'Automated feedback' })
  ).toHaveAttribute('aria-expanded', 'true')
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
    screen.queryByRole('button', { name: 'How you solved the exercise' })
  ).not.toBeInTheDocument()
})
