import { toSentence } from '@/utils/toSentence'
import { EvaluationResultMethodCallStatement } from '../evaluation-result'
import { MethodCallExpression } from '../expression'
import { DescriptionContext, FrameWithResult } from '../frames'
import { codeTag, formatJikiObject } from '../helpers'
import { MethodCallStatement } from '../statement'
import { describeExpression } from './describeSteps'
import * as Jiki from '../jikiObjects'

export function describeMethodCallStatement(
  frame: FrameWithResult,
  context: DescriptionContext
) {
  const frameContext = frame.context as MethodCallStatement
  const frameResult = frame.result as EvaluationResultMethodCallStatement
  const expression = frameContext.expression as MethodCallExpression

  const methodName = expression.methodName.lexeme

  const args = ((args) => {
    return toSentence(
      args.map((arg, idx) =>
        codeTag(
          formatJikiObject(arg.jikiObject),
          frameContext.expression.args[idx].location
        )
      )
    )
  })(frameResult.expression.args)

  const instance = frameResult.expression.object.jikiObject as Jiki.Instance
  const instanceDesc = `${instance.getClassName()} instance's`

  const methodCallCodeTag = codeTag(methodName, expression.methodName.location)
  const argsDesc = args.length > 0 ? ` with the inputs ${args}` : ''
  const result = `<p>This used the ${instanceDesc} ${methodCallCodeTag} method${argsDesc}.</p>`

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
