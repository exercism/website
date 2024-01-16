import { assembleClassNames } from '@/utils/assemble-classnames'

describe('assembleClassNames function', () => {
  test('should handle string arguments', () => {
    expect(assembleClassNames('first', 'second')).toEqual('first second')
  })

  test('should filter out undefined values', () => {
    expect(assembleClassNames('first', undefined)).toEqual('first')
  })

  test('should filter out null values', () => {
    expect(assembleClassNames('first', null)).toEqual('first')
  })

  test('should filter out empty strings', () => {
    expect(assembleClassNames('', 'first', ' ', 'second')).toEqual(
      'first second'
    )
  })

  test('should handle trimming of class names', () => {
    expect(assembleClassNames('  first  ', ' second')).toEqual('first second')
  })

  test('should handle duplicate class names', () => {
    expect(
      assembleClassNames('first', 'second', 'first', 'second', 'third')
    ).toEqual('first second third')
  })

  test('should handle boolean values', () => {
    expect(assembleClassNames('first', false, 'second', true)).toEqual(
      'first second'
    )
  })

  test('should return an empty string for no valid inputs', () => {
    expect(assembleClassNames('', null, undefined, false)).toEqual('')
  })
})
