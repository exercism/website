import { DescriptionContext } from '@/interpreter/frames'
import { Location } from '@/interpreter/location'
import { Span } from '@/interpreter/location'

export const assertHTML = (actual, result, steps) => {
  const tidy = (text) =>
    text
      .split('\n')
      .map((line) => line.trim())
      .filter((line) => line.length > 0)
      .flat() // Remove nils
      .join('\n')
      .replaceAll(/>\s+/g, '>')
      .replaceAll(/\s+</g, '<')

  const expected = `<h3>What happened</h3>
       ${result}
       <hr/>
       <h3>Steps Jiki Took</h3>
       <ul>
       ${steps.join('\n')}
      </ul>`

  expect(tidy(actual)).toBe(tidy(expected))
}

export const location = new Location(0, new Span(0, 0), new Span(0, 0))
export const getNameFunction = {
  name: 'get_name',
  func: (_interpreter: any) => {
    return 'Jeremy'
  },
  description: 'always returns the string Jeremy',
}
export const getNameWithArgsFunction = {
  name: 'get_name',
  func: (_: any, _2: any) => {
    return 'Jeremy'
  },
  description: 'always returns the string Jeremy',
}

export const getTrueFunction = {
  name: 'get_true',
  func: (_interpreter: any) => {
    return true
  },
  description: '',
}
export const getFalseFunction = {
  name: 'get_false',
  func: (_interpreter: any) => {
    return false
  },
  description: '',
}

export const mehFunction = {
  name: 'meh',
  func: (_: any) => {},
  description: 'is a little meh',
}

export const mehWithArgsFunction = {
  name: 'meh',
  func: (_: any, _2: any) => {},
  description: 'is a little meh',
}

export const contextToDescriptionContext = (context): DescriptionContext => {
  // Convert array into object with name as key
  // and description as value
  const funcs = context.externalFunctions.reduce((acc, fn) => {
    acc[fn.name] = fn.description
    return acc
  }, {})

  return {
    functionDescriptions: funcs,
  }
}
