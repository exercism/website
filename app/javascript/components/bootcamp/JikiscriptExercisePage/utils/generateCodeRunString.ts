import { formatJikiObject } from '@/interpreter/helpers'

export function generateCodeRunString(fn: string | undefined, args: any[]) {
  if (fn === undefined) return 'Your function is not defined'
  if (!fn || !args) return ''
  args = args.map((p) => formatJikiObject(p))
  return `${fn}(${args.join(', ')})`
}
