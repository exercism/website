import React from 'react'
import { render, fireEvent } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { TagsFilter } from '../../../../../app/javascript/components/student/tracks-list/TagsFilter'

test('hides option list when clicking "Close"', () => {
  const { getByText, queryByText } = render(
    <TagsFilter
      options={[
        { category: 'Paradigm', options: [{ value: 'oop', label: 'OOP' }] },
      ]}
      value={[]}
    />
  )

  fireEvent.click(getByText('Filter by'))
  fireEvent.click(getByText('Close'))

  expect(queryByText('OOP')).not.toBeVisible()
})

test('focuses on dialog when expanded', () => {
  const { getByText, getByRole } = render(
    <TagsFilter
      options={[
        { category: 'Paradigm', options: [{ value: 'oop', label: 'OOP' }] },
      ]}
      value={[]}
    />
  )

  fireEvent.click(getByText('Filter by'))

  expect(getByRole('dialog')).toHaveFocus()
})

test('focuses on filter only after expanding and closing', () => {
  const { getByText, getByRole } = render(
    <TagsFilter
      options={[
        { category: 'Paradigm', options: [{ value: 'oop', label: 'OOP' }] },
      ]}
      value={[]}
    />
  )

  fireEvent.click(getByText('Filter by'))
  fireEvent.click(getByText('Close'))

  expect(getByRole('button', { name: /filter by/i })).toHaveFocus()
})

test('does not focus on filter by default', () => {
  const { getByText, getByRole } = render(
    <TagsFilter
      options={[
        { category: 'Paradigm', options: [{ value: 'oop', label: 'OOP' }] },
      ]}
      value={[]}
    />
  )

  expect(getByText('Filter by')).not.toHaveFocus()
})
