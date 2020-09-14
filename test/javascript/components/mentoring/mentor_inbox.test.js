import React from 'react'
import { render } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { reducer } from '../../../../app/javascript/components/mentoring/mentor_inbox'

test('reducer resets page to 1 when switching tracks', () => {
  expect(
    reducer(
      { query: { page: 2 } },
      { type: 'track.changed', payload: { track: 2 } }
    )
  ).toEqual({ query: { page: 1, track: 2 } })
})
