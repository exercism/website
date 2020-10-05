import React from 'react'
import { render, fireEvent } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { StatusFilter } from '../../../../../app/javascript/components/student/tracks-list/StatusFilter'

test('disables currently selected status', () => {
  const options = [
    { label: 'Joined', value: 'joined' },
    { label: 'Unjoined', value: 'unjoined' },
  ]
  const { getByText } = render(
    <StatusFilter value="joined" options={options} dispatch={() => {}} />
  )

  expect(getByText('Joined')).toBeDisabled()
  expect(getByText('Unjoined')).not.toBeDisabled()
})

test('disables first status if no value is passed in', () => {
  const options = [
    { label: 'Joined', value: 'joined' },
    { label: 'Unjoined', value: 'unjoined' },
  ]
  const { getByText } = render(
    <StatusFilter options={options} dispatch={() => {}} />
  )

  expect(getByText('Joined')).toBeDisabled()
  expect(getByText('Unjoined')).not.toBeDisabled()
})
