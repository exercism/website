import '@testing-library/jest-dom/extend-expect'

import {
  fromNow,
  shortFromNow,
  durationFromSeconds,
  durationTimeElementFromSeconds,
} from '../../../app/javascript/utils/time'

test('fromNow', () => {
  var time = new Date()
  time.setDate(time.getDate() - 2)
  expect(fromNow(time)).toEqual('2 days ago')
})

test('shortFromNow for now future', () => {
  var time = new Date()
  time.setTime(time.getTime() + 1)
  expect(shortFromNow(time)).toEqual('now')
})

test('shortFromNow for minute future', () => {
  var time = new Date()
  time.setTime(time.getTime() + 1 * 60 * 1000)
  expect(shortFromNow(time)).toEqual('in 1m')
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

test('shortFromNow for 2 months', () => {
  var time = new Date()
  time.setDate(time.getDate() - 60)
  expect(shortFromNow(time)).toEqual('2mo ago')
})

test('durationFromSeconds for 43 seconds', () => {
  expect(durationFromSeconds(43)).toEqual('43 seconds')
})

test('durationFromSeconds for 1 minute', () => {
  expect(durationFromSeconds(60 + 5)).toEqual('1 minute')
})

test('durationFromSeconds for 16 minutes', () => {
  expect(durationFromSeconds(60 * 15 + 5)).toEqual('15 minutes')
})

test('durationFromSeconds for 1 hour', () => {
  expect(durationFromSeconds(60 * 60)).toEqual('1 hour')
})

test('durationFromSeconds for 1 day', () => {
  expect(durationFromSeconds(60 * 60 * 24)).toEqual('1 day')
})

test('durationFromSeconds for 2 days', () => {
  expect(durationFromSeconds(60 * 60 * 24 * 2)).toEqual('2 days')
})

test('durationFromSeconds for 1 month', () => {
  expect(durationFromSeconds(60 * 60 * 24 * 35)).toEqual('1 month')
})

test('durationFromSeconds for 2 months', () => {
  expect(durationFromSeconds(60 * 60 * 24 * 70)).toEqual('2 months')
})

test('durationTimeElementFromSeconds for 1 second', () => {
  expect(durationTimeElementFromSeconds(1)).toEqual('P 0D 0H 0M 1S')
})

test('durationTimeElementFromSeconds for 2 seconds', () => {
  expect(durationTimeElementFromSeconds(2)).toEqual('P 0D 0H 0M 2S')
})

test('durationTimeElementFromSeconds for 1 minute', () => {
  expect(durationTimeElementFromSeconds(60)).toEqual('P 0D 0H 1M 0S')
})

test('durationTimeElementFromSeconds for 2 minutes', () => {
  expect(durationTimeElementFromSeconds(60 * 2)).toEqual('P 0D 0H 2M 0S')
})

test('durationTimeElementFromSeconds for 1 hour', () => {
  expect(durationTimeElementFromSeconds(60 * 60)).toEqual('P 0D 1H 0M 0S')
})

test('durationTimeElementFromSeconds for 1 hour', () => {
  expect(durationTimeElementFromSeconds(60 * 60 * 2)).toEqual('P 0D 2H 0M 0S')
})

test('durationTimeElementFromSeconds for 1 day', () => {
  expect(durationTimeElementFromSeconds(60 * 60 * 24)).toEqual('P 1D 0H 0M 0S')
})

test('durationTimeElementFromSeconds for 2 days', () => {
  expect(durationTimeElementFromSeconds(60 * 60 * 24 * 2)).toEqual(
    'P 2D 0H 0M 0S'
  )
})

test('durationTimeElementFromSeconds for combination', () => {
  expect(
    durationTimeElementFromSeconds(
      60 * 60 * 24 * 2 + 60 * 60 * 3 + 60 * 22 + 55
    )
  ).toEqual('P 2D 3H 22M 55S')
})
