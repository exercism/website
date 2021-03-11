import '@testing-library/jest-dom/extend-expect'

import { fromNow, shortFromNow } from '../../../app/javascript/utils/time'

test('fromNow', () => {
  var time = new Date()
  time.setDate(time.getDate() - 2)
  expect(fromNow(time)).toEqual('2 days ago')
})

test('shortFromNow', () => {
  var time = new Date()
  time.setDate(time.getDate() - 2)
  expect(shortFromNow(time)).toEqual('2d ago')
})
