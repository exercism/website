import '@testing-library/jest-dom/extend-expect'

import { fromNow } from '../../../app/javascript/utils/date'

test('fromNow - same day', () => {
  var date = new Date()
  expect(fromNow(date)).toEqual('today')
})

test('fromNow - yesterday', () => {
  var date = new Date()
  date.setDate(date.getDate() - 1)
  expect(fromNow(date)).toEqual('yesterday')
})

test('fromNow - multiple ago', () => {
  var date = new Date()
  date.setDate(date.getDate() - 5)
  expect(fromNow(date)).toEqual('5 days ago')
})

test('fromNow - one week ago', () => {
  var date = new Date()
  date.setDate(date.getDate() - 7)
  expect(fromNow(date)).toEqual('1 week ago')
})

test('fromNow - multiple weeks ago', () => {
  var date = new Date()
  date.setDate(date.getDate() - 21)
  expect(fromNow(date)).toEqual('3 weeks ago')
})

test('fromNow - one month ago', () => {
  var date = new Date()
  date.setDate(date.getDate() - 31)
  expect(fromNow(date)).toEqual('1 month ago')
})

test('fromNow - multiple months ago', () => {
  var date = new Date()
  date.setDate(date.getDate() - 300)
  expect(fromNow(date)).toEqual('9 months ago')
})

test('fromNow - one year ago', () => {
  var date = new Date()
  date.setDate(date.getDate() - 366)
  expect(fromNow(date)).toEqual('1 year ago')
})

test('fromNow - multiple years ago', () => {
  var date = new Date()
  date.setDate(date.getDate() - 800)
  expect(fromNow(date)).toEqual('2 years ago')
})
