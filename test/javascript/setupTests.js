import 'react-app-polyfill/ie9'
import '@testing-library/jest-dom/extend-expect'
import { waitFor, act } from '@testing-library/react'
import { queryCache } from 'react-query'
import flushPromises from 'flush-promises'

jest.mock('../../app/javascript/utils/action-cable-consumer')
jest.retryTimes(3)

// https://jestjs.io/docs/manual-mocks#mocking-methods-which-are-not-implemented-in-jsdom
Object.defineProperty(window, 'matchMedia', {
  writable: true,
  value: jest.fn().mockImplementation((query) => ({
    matches: false,
    media: query,
    onchange: null,
    addListener: jest.fn(), // deprecated
    removeListener: jest.fn(), // deprecated
    addEventListener: jest.fn(),
    removeEventListener: jest.fn(),
    dispatchEvent: jest.fn(),
  })),
})

afterEach(async () => {
  queryCache.cancelQueries()
  queryCache.clear()

  // waitFor is important here. If there are queries that are being fetched at
  // the end of the test and we continue on to the next test before waiting for
  // them to finalize, the tests can impact each other in strange ways.
  // eslint-disable-next-line jest/no-standalone-expect
  await waitFor(() => expect(queryCache.isFetching).toBe(0))

  await flushPromises()
  await act(async () => await null)
})
