import type { FunctionParameter } from '@/interpreter/statement'
import type { Token } from '../token'
import type { ErrorType } from '@/interpreter/error'

export function errorForMissingDoAfterParameters(
  token: Token,
  parameters: FunctionParameter[]
): { errorType: ErrorType; context: {} } {
  if (token.type == 'EOL') {
    return {
      errorType: 'MissingDoToStartBlock',
      context: {
        type: 'function',
      },
    }
  }

  if (token.type == 'IDENTIFIER') {
    if (parameters.length == 0) {
      return {
        errorType: 'MissingWithBeforeParameters',
        context: {},
      }
    } else {
      return {
        errorType: 'MissingCommaBetweenParameters',
        context: {
          parameter: parameters[parameters.length - 1].name.lexeme,
        },
      }
    }
  }

  return {
    errorType: 'UnexpectedTokenAfterParameters',
    context: {},
  }
}
// this.error("MissingCommaAfterParameter", , { parameter: parameters[-1].name })
