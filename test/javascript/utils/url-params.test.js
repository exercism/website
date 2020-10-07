import { UrlParams } from '../../../app/javascript/utils/url-params'

test('toString() returns empty string when object is null', () => {
  expect(new UrlParams(null).toString()).toEqual('')
})

test('toString() returns empty string when object is undefined', () => {
  expect(new UrlParams(undefined).toString()).toEqual('')
})

test('toString() converts arrays correctly', () => {
  const object = { tags: ['oop', 'static'], foo: 'bar' }

  expect(new UrlParams(object).toString()).toEqual('tags[]=oop&tags[]=static')
})
