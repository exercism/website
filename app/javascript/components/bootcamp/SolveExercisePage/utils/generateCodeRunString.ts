import { formatJikiObject } from '@/interpreter/helpers'

export function generateCodeRunString(fn: string, args: any[]) {
  if (!fn || !args) return ''
  args = args.map((p) => formatJikiObject(p))
  return `${fn}(${args.join(', ')})`
}
