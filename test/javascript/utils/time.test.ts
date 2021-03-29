import '@testing-library/jest-dom/extend-expect'

import { fromNow, shortFromNow } from '../../../app/javascript/utils/time'

test('fromNow', () => {
  var time = new Date()
  time.setDate(time.getDate() - 2)
  expect(fromNow(time)).toEqual('2 days ago')
})

test('shortFromNow for now', () => {
  var time = new Date()
  time.setDate(time.getDate())
  expect(shortFromNow(time)).toEqual('now')
})

test('shortFromNow for 1hr', () => {
  var time = new Date()
  time.setTime(time.getTime() - 60 * 60 * 1000)
  expect(shortFromNow(time)).toEqual('1h ago')
})

test('shortFromNow for 1d', () => {
  var time = new Date()
  time.setDate(time.getDate() - 0.001)
  expect(shortFromNow(time)).toEqual('1d ago')
})

test('shortFromNow for 2d', () => {
  var time = new Date()
  time.setDate(time.getDate() - 2)
  expect(shortFromNow(time)).toEqual('2d ago')
})
