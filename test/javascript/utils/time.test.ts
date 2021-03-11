import '@testing-library/jest-dom/extend-expect'

import { fromNow } from '../../../app/javascript/utils/time'

test('works without short', () => {
  var time = new Date()
  time.setDate(time.getDate() - 2)

  expect(fromNow(time, null)).toEqual('2 days ago')
  expect(fromNow(time, false)).toEqual('2 days ago')
  expect(fromNow(time)).toEqual('2 days ago')
})

test('works with short', () => {
  var time = new Date()
  time.setDate(time.getDate() - 2)

  expect(fromNow(time, true)).toEqual('2d ago')
})
