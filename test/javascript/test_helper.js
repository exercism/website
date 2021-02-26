import fetch from 'isomorphic-fetch'
import '@testing-library/jest-dom/extend-expect'
import { queryCache } from 'react-query'

global.fetch = fetch

afterEach(async () => {
  queryCache.clear()
})
