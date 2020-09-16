import React from 'react'
import { render, fireEvent } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { Pagination } from '../../../../../app/javascript/components/mentoring/mentor_conversations_list/pagination.jsx'

test('clicking on "First" sets page to 1', () => {
  const setPage = jest.fn()
  const { getByText } = render(
    <Pagination current={2} total={10} setPage={setPage} />
  )

  fireEvent.click(getByText('First'))

  expect(setPage.mock.calls).toEqual([[1]])
})

test('"First" button has correct aria-label tag', () => {
  const { getByText } = render(<Pagination current={1} total={1} />)

  const button = getByText('First')

  expect(button).toHaveAttribute('aria-label', 'Go to first page')
})

test('"First" button has an aria-current tag if on the first page', () => {
  const { getByText } = render(<Pagination current={1} total={1} />)

  const button = getByText('First')

  expect(button).toHaveAttribute('aria-current', 'page')
})

test('"First" button does not have an aria-current tag if not on the first page', () => {
  const { getByText } = render(<Pagination current={2} total={2} />)

  const button = getByText('First')

  expect(button).not.toHaveAttribute('aria-current')
})

test('"First" button is disabled if current is 1', () => {
  const setPage = jest.fn()
  const { getByText } = render(
    <Pagination current={1} total={10} setPage={setPage} />
  )

  const button = getByText('First')
  expect(button).toBeDisabled()
})

test('clicking on "Last" sets page to last page', () => {
  const setPage = jest.fn()
  const { getByText } = render(
    <Pagination current={2} total={10} setPage={setPage} />
  )

  fireEvent.click(getByText('Last'))

  expect(setPage.mock.calls).toEqual([[10]])
})

test('"Last" button is disabled when current = total', () => {
  const setPage = jest.fn()
  const { getByText } = render(
    <Pagination current={10} total={10} setPage={setPage} />
  )

  const button = getByText('Last')
  expect(button).toBeDisabled()
})

test('"Last" button has correct aria-label tag', () => {
  const { getByText } = render(<Pagination current={1} total={1} />)

  const button = getByText('Last')

  expect(button).toHaveAttribute('aria-label', 'Go to last page')
})

test('"Last" button has an aria-current tag if on the last page', () => {
  const { getByText } = render(<Pagination current={1} total={1} />)

  const button = getByText('Last')

  expect(button).toHaveAttribute('aria-current', 'page')
})

test('"Last" button does not have an aria-current tag if not on the first page', () => {
  const { getByText } = render(<Pagination current={1} total={2} />)

  const button = getByText('Last')

  expect(button).not.toHaveAttribute('aria-current')
})

test('clicking on page button sets page', () => {
  const setPage = jest.fn()
  const { getByText } = render(
    <Pagination current={2} total={10} setPage={setPage} />
  )

  fireEvent.click(getByText('3'))

  expect(setPage.mock.calls).toEqual([[3]])
})

test('page button has correct aria-label tag', () => {
  const { getByText } = render(<Pagination current={1} total={1} />)

  const button = getByText('1')

  expect(button).toHaveAttribute('aria-label', 'Go to page 1')
})

test('page button has an aria-current tag if on the page', () => {
  const { getByText } = render(<Pagination current={1} total={1} />)

  const button = getByText('1')

  expect(button).toHaveAttribute('aria-current', 'page')
})

test('page button does not have an aria-current tag if not on the page', () => {
  const { getByText } = render(<Pagination current={1} total={2} />)

  const button = getByText('2')

  expect(button).not.toHaveAttribute('aria-current')
})

test('button for current page is disabled', () => {
  const { getByText } = render(<Pagination current={2} total={10} />)

  const button = getByText('2')
  expect(button).toBeDisabled()
})

test('shows buttons around the current page', () => {
  const { queryByText } = render(
    <Pagination current={2} total={10} around={1} />
  )

  expect(queryByText('1')).toBeTruthy()
  expect(queryByText('3')).toBeTruthy()
  expect(queryByText('4')).toBeNull()
})

test('only shows counting number pages', () => {
  const { queryByText } = render(
    <Pagination current={1} total={10} around={1} />
  )

  expect(queryByText('0')).toBeNull()
})

test('does not show pages above the total', () => {
  const { queryByText } = render(
    <Pagination current={10} total={10} around={1} />
  )

  expect(queryByText('11')).toBeNull()
})
