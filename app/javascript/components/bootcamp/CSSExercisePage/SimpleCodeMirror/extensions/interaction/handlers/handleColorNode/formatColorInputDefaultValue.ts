import { rgb2hex } from '../../utils'

export function formatColorInputDefaultValue(input: string): string {
  if (input.startsWith('#')) return input

  const match = input.match(/rgb\s*\(\s*(\d+)[,\s]+(\d+)[,\s]+(\d+)\s*\)/)
  if (match) {
    const [r, g, b] = match.slice(1).map(Number)
    return rgb2hex(r, g, b)
  }

  return '#000000'
}
