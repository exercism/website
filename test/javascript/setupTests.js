import '@testing-library/jest-dom/extend-expect'
import { waitFor, act } from '@testing-library/react'
import { queryCache } from 'react-query'
import flushPromises from 'flush-promises'

jest.mock('../../app/javascript/utils/action-cable-consumer')

afterEach(async () => {
  queryCache.cancelQueries()
  queryCache.clear()

  // waitFor is important here. If there are queries that are being fetched at
  // the end of the test and we continue on to the next test before waiting for
  // them to finalize, the tests can impact each other in strange ways.
  await waitFor(() => expect(queryCache.isFetching).toBe(0))

  await flushPromises()
  await act(async () => await null)
})
