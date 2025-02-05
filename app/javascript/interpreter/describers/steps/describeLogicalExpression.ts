import {
  EvaluationResultFullyEvaluatedLogicalExpression,
  EvaluationResultLogicalExpression,
} from '../../evaluation-result'
import { LogicalExpression } from '../../expression'
import { describeExpression } from '../describeSteps'

export function describeLogicalExpression(
  expression: LogicalExpression,
  result: EvaluationResultLogicalExpression
) {
  return result.right == null
    ? describeShortCircuitedExpression(expression, result)
    : describeFullExpression(expression, result)
}

function describeShortCircuitedExpression(
  expression: LogicalExpression,
  result: EvaluationResultLogicalExpression
) {
  let steps = describeExpression(expression.left, result.left)
  steps = [
    ...steps,
    `<li>Jiki saw the left side of the <code>${expression.operator.lexeme}</code> was <code>${result.left.value}</code> and so did not bother looking at the right side.</li>`,
  ]
  return steps
}

function describeFullExpression(
  expression: LogicalExpression,
  result: EvaluationResultFullyEvaluatedLogicalExpression
) {
  if (result.right == null) {
    return []
  }
  return [
    ...describeExpression(expression.left, result.left),
    ...describeExpression(expression.right, result.right),
    `<li>Jiki evaluated <code>${result.left.value} ${expression.operator.lexeme} ${result.right.value}</code> and determined the result was <code>${result.value}</code>.</li>`,
  ]
}
/*
  
  let leftSteps;
  if(expression.left.type === 'LiteralExpression') {
  }
  else {
    leftSteps = describeExpression(expression.left, result.left)
  }
  if(!result.right) {
    const finalStep = `<li>Jiki did not bother looking at the right of the ${expression.operator.lexeme} because the left was <code>${result.value}</code>.</li>`
    return [...leftSteps, finalStep]
  }
  const rightSteps = describeExpression(expression.right, result.right)

  const finalStep = `<li>Jiki evaluated <code>${result.left.value} ${expression.operator.lexeme} ${result.right.value}</code> and determined it was <code>${result.value}</code>.</li>`
  return [...leftSteps, ...rightSteps, finalStep]
  
}
*/
