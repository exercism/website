import { formatJikiObject } from '@/interpreter/helpers'

export function generateCodeRunString(fn: string, params: any[]) {
  if (!fn || !params) return ''
  params = params.map((p) => formatJikiObject(p))
  return `${fn}(${params.join(', ')})`
}
