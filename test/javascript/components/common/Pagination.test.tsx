import React from 'react'
import { render, fireEvent, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import '@testing-library/jest-dom/extend-expect'
import { Pagination } from '../../../../app/javascript/components/common/Pagination'

test('shows nothing if total is <= 1', () => {
  render(<Pagination current={2} total={1} setPage={jest.fn()} />)

  expect(
    screen.queryByRole('button', { name: 'Go to first page' })
  ).not.toBeInTheDocument()
})

test('clicking on "First" sets page to 1', () => {
  const setPage = jest.fn()
  const { getByText } = render(
    <Pagination current={2} total={10} setPage={setPage} />
  )

  fireEvent.click(getByText('First'))

  expect(setPage.mock.calls).toEqual([[1]])
})

test('"First" button has correct aria-label tag', () => {
  const { getByText } = render(
    <Pagination current={2} total={2} setPage={jest.fn()} />
  )

  const button = getByText('First')

  expect(button).toHaveAttribute('aria-label', 'Go to first page')
})

test('"First" button does not have an aria-current tag if not on the first page', () => {
  const { getByText } = render(
    <Pagination current={2} total={2} setPage={jest.fn()} />
  )

  const button = getByText('First')

  expect(button).not.toHaveAttribute('aria-current')
})

test('"First" button is disabled if current is 1', () => {
  render(<Pagination current={1} total={10} setPage={jest.fn()} />)

  expect(
    screen.getByRole('button', { name: 'Go to first page' })
  ).toBeDisabled()
})

test('clicking on "Last" sets page to last page', () => {
  const setPage = jest.fn()
  const { getByText } = render(
    <Pagination current={2} total={10} setPage={setPage} />
  )

  fireEvent.click(getByText('Last'))

  expect(setPage.mock.calls).toEqual([[10]])
})

test('"Last" button has correct aria-label tag', () => {
  const { getByText } = render(
    <Pagination current={1} total={2} setPage={jest.fn()} />
  )

  const button = getByText('Last')

  expect(button).toHaveAttribute('aria-label', 'Go to last page')
})

test('"Last" button is disabled when on the last page', () => {
  render(<Pagination current={2} total={2} setPage={jest.fn()} />)

  expect(screen.getByRole('button', { name: 'Go to last page' })).toBeDisabled()
})

test('"Last" button does not have an aria-current tag if not on the first page', () => {
  const { getByText } = render(
    <Pagination current={1} total={2} setPage={jest.fn()} />
  )

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
  const { getByText } = render(
    <Pagination current={1} total={2} setPage={jest.fn()} />
  )

  const button = getByText('1')

  expect(button).toHaveAttribute('aria-label', 'Go to page 1')
})

test('page button has an aria-current tag if on the page', () => {
  const { getByText } = render(
    <Pagination current={1} total={2} setPage={jest.fn()} />
  )

  const button = getByText('1')

  expect(button).toHaveAttribute('aria-current', 'page')
})

test('page button has the "current" className if on the page', () => {
  const { getByText } = render(
    <Pagination current={1} total={2} setPage={jest.fn()} />
  )

  const button = getByText('1')

  expect(button).toHaveAttribute('class', 'current')
})

test('page button does not have an aria-current tag if not on the page', () => {
  const { getByText } = render(
    <Pagination current={1} total={2} setPage={jest.fn()} />
  )

  const button = getByText('2')

  expect(button).not.toHaveAttribute('aria-current')
})

test('page button does not have the "current" className if not on the page', () => {
  const { getByText } = render(
    <Pagination current={1} total={2} setPage={jest.fn()} />
  )

  const button = getByText('2')

  expect(button).not.toHaveAttribute('className')
})

test('button for current page is disabled', () => {
  const { getByText } = render(
    <Pagination current={2} total={10} setPage={jest.fn()} />
  )

  const button = getByText('2')
  expect(button).toBeDisabled()
})

test('shows buttons around the current page', () => {
  const { queryByText } = render(
    <Pagination current={2} total={10} around={1} setPage={jest.fn()} />
  )

  expect(queryByText('1')).toBeTruthy()
  expect(queryByText('3')).toBeTruthy()
  expect(queryByText('4')).toBeNull()
})

test('only shows counting number pages', () => {
  const { queryByText } = render(
    <Pagination current={1} total={10} around={1} setPage={jest.fn()} />
  )

  expect(queryByText('0')).toBeNull()
})

test('does not show pages above the total', () => {
  const { queryByText } = render(
    <Pagination current={10} total={10} around={1} setPage={jest.fn()} />
  )

  expect(queryByText('11')).toBeNull()
})

test('clicking on "Previous" button sets previous page', () => {
  const setPage = jest.fn()

  render(<Pagination current={2} total={10} setPage={setPage} />)
  userEvent.click(screen.getByRole('button', { name: 'Go to previous page' }))

  expect(setPage.mock.calls).toEqual([[1]])
})

test('"Previous" button is disabled when on the first page', () => {
  render(<Pagination current={1} total={10} setPage={jest.fn()} />)

  expect(
    screen.getByRole('button', { name: 'Go to previous page' })
  ).toBeDisabled()
})

test('clicking on "Next" button sets next page', () => {
  const setPage = jest.fn()

  render(<Pagination current={2} total={10} setPage={setPage} />)
  userEvent.click(screen.getByRole('button', { name: 'Go to next page' }))

  expect(setPage.mock.calls).toEqual([[3]])
})

test('"Next" button is disabled when on the last page', () => {
  render(<Pagination current={10} total={10} setPage={jest.fn()} />)

  expect(screen.getByRole('button', { name: 'Go to next page' })).toBeDisabled()
})

test('shows left gap indicator when above the window', () => {
  render(<Pagination current={3} total={6} around={1} setPage={jest.fn()} />)

  expect(screen.getByText('…')).toBeInTheDocument()
})

test('hides left gap indicator when above the window', () => {
  render(<Pagination current={2} total={3} around={1} setPage={jest.fn()} />)

  expect(screen.queryByText('…')).not.toBeInTheDocument()
})

test('shows right gap indicator when above the window', () => {
  render(<Pagination current={1} total={5} around={1} setPage={jest.fn()} />)

  expect(screen.getByText('…')).toBeInTheDocument()
})

test('hides right gap indicator when above the window', () => {
  render(<Pagination current={2} total={3} around={1} setPage={jest.fn()} />)

  expect(screen.queryByText('…')).not.toBeInTheDocument()
})

test('shows nothing if current is above total', () => {
  render(<Pagination current={4} total={3} around={1} setPage={jest.fn()} />)

  expect(
    screen.queryByRole('button', { name: 'Go to first page' })
  ).not.toBeInTheDocument()
})

test('shows nothing if current is below one', () => {
  render(<Pagination current={0} total={3} around={1} setPage={jest.fn()} />)

  expect(
    screen.queryByRole('button', { name: 'Go to first page' })
  ).not.toBeInTheDocument()
})

test('sets page to last page if current is above total', () => {
  const setPage = jest.fn()

  render(<Pagination current={4} total={3} setPage={setPage} />)

  expect(setPage.mock.calls).toEqual([[3]])
})

test('sets page to first page if current is below one', () => {
  const setPage = jest.fn()

  render(<Pagination current={0} total={3} setPage={setPage} />)

  expect(setPage.mock.calls).toEqual([[1]])
})
