import { Location } from '@/interpreter/location'
import { Span } from '@/interpreter/location'

export const assertHTML = (actual, markdown) => {
  const tidy = (text) =>
    text
      .split('\n')
      .map((line) => line.trim())
      .filter((line) => line.length > 0)
      .flat() // Remove nils
      .join('\n')
      .replaceAll(/>\s+/g, '>')
      .replaceAll(/\s+</g, '<')

  expect(tidy(actual)).toBe(tidy(markdown))
}

export const location = new Location(0, new Span(0, 0), new Span(0, 0))
export const getNameFunction = {
  name: 'get_name',
  func: (_interpreter: any) => {
    return 'Jeremy'
  },
  description: '',
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
