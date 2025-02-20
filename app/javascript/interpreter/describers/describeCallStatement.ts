import { toSentence } from '@/utils/toSentence'
import { EvaluationResultCallStatement } from '../evaluation-result'
import { CallExpression } from '../expression'
import { DescriptionContext, FrameWithResult } from '../frames'
import { codeTag, formatLiteral } from '../helpers'
import { CallStatement } from '../statement'
import { describeExpression } from './describeSteps'

export function describeCallStatement(
  frame: FrameWithResult,
  context: DescriptionContext
) {
  const frameContext = frame.context as CallStatement
  const frameResult = frame.result as EvaluationResultCallStatement
  const expression = frameContext.expression as CallExpression

  const fnName = expression.callee.name.lexeme

  const args = ((args) => {
    return toSentence(
      args.map((arg, idx) =>
        codeTag(
          formatLiteral(arg.jikiObject),
          frameContext.expression.args[idx].location
        )
      )
    )
  })(frameResult.expression.args)

  const argsDesc = args.length > 0 ? ` with the inputs ${args}` : ''
  const result = `<p>This used the ${codeTag(
    fnName,
    expression.callee.location
  )} function${argsDesc}.</p>`

  let steps = describeExpression(
    frameContext.expression,
    frameResult.expression,
    context
  )

  return {
    result: result,
    steps: steps,
  }
}
