import { waitFor } from '@testing-library/react'
import { queryCache } from 'react-query'
import flushPromises from 'flush-promises'
import { act } from '@testing-library/react'

afterEach(async () => {
  queryCache.clear()

  // waitFor is important here. If there are queries that are being fetched at
  // the end of the test and we continue on to the next test before waiting for
  // them to finalize, the tests can impact each other in strange ways.
  await waitFor(() => expect(queryCache.isFetching).toBe(0))

  await flushPromises()
  return act(async () => await null)
})
