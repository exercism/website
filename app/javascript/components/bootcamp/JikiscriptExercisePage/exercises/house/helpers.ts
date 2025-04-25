import { ExecutionContext } from '@/interpreter/executor'
import * as Jiki from '@/interpreter/jikiObjects'

export const guardValidHex = (
  executionCtx: ExecutionContext,
  hex: Jiki.JikiObject
) => {
  if (!(hex instanceof Jiki.String)) {
    return executionCtx.logicError('Hex must be a string')
  }
  if (!/^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$/.test(hex.value)) {
    return executionCtx.logicError('Invalid hex value')
  }
}
