import { formatLiteral } from '@/interpreter/helpers'

export function generateCodeRunString(fn: string, params: any[]) {
  if (!fn || !params) return ''
  params = params.map((p) => formatLiteral(p))
  return `${fn}(${params.join(', ')})`
}
