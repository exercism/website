import type {
  Token as JikiscriptToken,
  TokenType as JikiscriptTokenType,
} from './languages/jikiscript/token'
import type {
  Token as JavascriptToken,
  TokenType as JavascriptTokenType,
} from './languages/javascript/token'

export type Token = JikiscriptToken | JavascriptToken
export type TokenType = JikiscriptTokenType | JavascriptTokenType
