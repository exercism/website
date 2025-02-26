import { isString } from '../checks'
import {
  EvaluationResultForeachStatement,
  EvaluationResultRepeatStatement,
} from '../evaluation-result'
import { Description, DescriptionContext, FrameWithResult } from '../frames'
import { codeTag, formatJikiObject } from '../helpers'
import { ForeachStatement, RepeatStatement } from '../statement'
import { describeExpression } from './describeSteps'
import { addOrdinalSuffix } from './helpers'

export function describeBreakStatement(
  _fr: FrameWithResult,
  _dc: DescriptionContext
): Description {
  const result = `<p>This line immediately exited the loop.</p>`
  const steps = [
    `<li>Jiki saw this and decided to move on to after this loop.</li>`,
  ]
  return { result, steps }
}
