import { isNumber } from 'lodash'
import {
  EvaluationResultClassLookupExpression,
  EvaluationResultExpression,
  EvaluationResultInstantiationExpression,
} from '../evaluation-result'
import { Executor } from '../executor'
import { BinaryExpression, InstantiationExpression } from '../expression'
import * as JikiTypes from '../jikiObjects'

// Add UnsetPropertiesError
export class UnsetPropertyError extends Error {
  constructor(public readonly property: string) {
    super('UnsetPropertiesError')
  }
}

export function executeInstantiationExpression(
  executor: Executor,
  expression: InstantiationExpression
): EvaluationResultInstantiationExpression {
  const className = executor.evaluate(
    expression.className
  ) as EvaluationResultClassLookupExpression
  try {
    const jikiClass = className.class

    const [minArity, maxArity] = isNumber(jikiClass.arity)
      ? [jikiClass.arity, jikiClass.arity]
      : jikiClass.arity

    if (
      expression.args.length < minArity ||
      expression.args.length > maxArity
    ) {
      executor.error(
        'WrongNumberOfArgumentsInConstructor',
        expression.location,
        {
          arity: minArity,
          numberOfArgs: expression.args.length,
        }
      )
    }
    const args: EvaluationResultExpression[] = []
    for (const arg of expression.args) {
      const evaluatedArg = executor.evaluate(arg)
      if (!(evaluatedArg.jikiObject instanceof JikiTypes.JikiObject)) {
        throw 'URGH'
      }
      args.push(evaluatedArg)
    }

    const object = jikiClass.instantiate(
      executor.getExecutionContext(),
      args.map((arg) => (arg.jikiObject as JikiTypes.JikiObject).toArg())
    )

    return {
      type: 'InstantiationExpression',
      jikiObject: object,
      className,
      args: args,
    }
  } catch (e) {
    if (e instanceof UnsetPropertyError) {
      executor.error('ConstructorDidNotSetProperty', expression.location, {
        property: e.property,
      })
    }
    throw e
  }
}
