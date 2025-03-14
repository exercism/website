import { set } from 'lodash'
import { EvaluationResultIfStatement } from '../evaluation-result'
import { ExecutionContext, Executor } from '../executor'
import { Expression, FunctionCallExpression } from '../expression'
import * as Jiki from '../jikiObjects'
import {
  ClassStatement,
  ConstructorStatement,
  PropertyStatement,
  SetPropertyStatement,
} from '../statement'
import { UserDefinedCallable } from '../functions'
import { Environment } from '../environment'
import stat from '@/components/impact/stat'

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

  statement.body.forEach((stmt) => {
    if (stmt.type == 'ConstructorStatement') {
      executeConstructorStatement(executor, klass, stmt as ConstructorStatement)
    } else if (stmt.type == 'MethodStatement') {
      executeMethodStatement(executor, klass, stmt)
    } else if (stmt.type == 'PropertyStatement') {
      console.log('here...')
      executePropertyStatement(executor, klass, stmt as PropertyStatement)
    }
  })
}

function executeConstructorStatement(
  executor: Executor,
  klass: Jiki.Class,
  stmt: ConstructorStatement
) {
  const fn = new UserDefinedCallable(stmt)
  klass.addConstructor(fn)
}

function executePropertyStatement(
  executor: Executor,
  klass: Jiki.Class,
  stmt: PropertyStatement
): void {
  klass.addProperty(stmt.name.lexeme)
  klass.addGetter(stmt.name.lexeme)
  klass.addSetter(stmt.name.lexeme)
}

/*

export function executeGetPropertyExpression(executor: Executor, statement: GetThisPropertyExpression) {

  this.executeFrame<EvaluationResultGetPropertyExpression>(
    statement,
    () => {
      
      
      executor.currentThis().getField(statement.property.lexeme)
}*/
