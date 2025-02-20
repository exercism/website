import {
  EvaluationResultFullyEvaluatedLogicalExpression,
  EvaluationResultLogicalExpression,
} from '../evaluation-result'
import { LogicalExpression } from '../expression'
import { DescriptionContext } from '../frames'
import { describeExpression } from './describeSteps'

export function describeLogicalExpression(
  expression: LogicalExpression,
  result: EvaluationResultLogicalExpression,
  context: DescriptionContext
) {
  return result.shortCircuited
    ? describeShortCircuitedExpression(expression, result, context)
    : describeFullExpression(expression, result, context)
}

function describeShortCircuitedExpression(
  expression: LogicalExpression,
  result: EvaluationResultLogicalExpression,
  context: DescriptionContext
) {
  let steps = describeExpression(expression.left, result.left, context)
  steps = [
    ...steps,
    `<li>Jiki saw the left side of the <code>${expression.operator.lexeme}</code> was <code>${result.left.jikiObject}</code> and so did not bother looking at the right side.</li>`,
  ]
  return steps
}

function describeFullExpression(
  expression: LogicalExpression,
  result: EvaluationResultFullyEvaluatedLogicalExpression,
  context: DescriptionContext
) {
  if (result.right == null) {
    return []
  }
  let inBetweenSteps: string[] = []
  if (expression.left.type === 'LiteralExpression') {
    inBetweenSteps.push(
      `<li>Jiki saw the left side of the <code>${expression.operator.lexeme}</code> was <code>${result.left.jikiObject}</code> and so decided to evaluate the right side.</li>`
    )
  }

  return [
    ...describeExpression(expression.left, result.left, context),
    ...inBetweenSteps,
    ...describeExpression(expression.right, result.right, context),
    `<li>Jiki evaluated <code>${result.left.jikiObject} ${expression.operator.lexeme} ${result.right.jikiObject}</code> and determined the result was <code>${result.jikiObject}</code>.</li>`,
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
