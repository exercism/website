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
    />
  )

  fireEvent.click(getByText('Filter by'))
  fireEvent.click(getByText('Close'))

  expect(queryByText('OOP')).not.toBeInTheDocument()
})
