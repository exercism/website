import { set } from 'lodash'
import { EvaluationResultIfStatement } from '../evaluation-result'
import { ExecutionContext, Executor } from '../executor'
import { Expression, FunctionCallExpression } from '../expression'
import * as Jiki from '../jikiObjects'
import { ClassStatement, ConstructorStatement } from '../statement'

export function executeClassStatement(
  executor: Executor,
  statement: ClassStatement
): void {
  executor.guardDefinedClass(statement.name)

  const klass = new Jiki.Class(statement.name.lexeme)

  statement.body.forEach((stmt) => {
    if (statement.type == 'ConstructorStatement') {
      executeConstructorStatement(executor, klass, stmt)
    }
  })

  executor.addClass(klass)
}

function executeConstructorStatement(
  executor: Executor,
  klass: Jiki.Class,
  stmt: ConstructorStatement
) {
  klass.addConstructor((executionCtx: ExecutionContext, stmt) => {})
}
