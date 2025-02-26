import { EvaluationResultIfStatement } from '../evaluation-result'
import { Executor } from '../executor'
import { Expression, FunctionCallExpression } from '../expression'
import { IfStatement } from '../statement'

export function executeIfStatement(executor: Executor, statement: IfStatement) {
  const conditionResult = executor.executeFrame<EvaluationResultIfStatement>(
    statement,
    () => executeCondition(executor, statement.condition)
  )

  if (conditionResult.jikiObject.value) {
    executor.executeStatement(statement.thenBranch)
    return
  }

  if (statement.elseBranch === null) return
  executor.executeStatement(statement.elseBranch!)
}

function executeCondition(
  executor: Executor,
  condition: Expression
): EvaluationResultIfStatement {
  const result = executor.evaluate(condition)
  executor.verifyBoolean(result.jikiObject, condition)

  return {
    type: 'IfStatement',
    condition: result,
    jikiObject: result.jikiObject,
  }
}
