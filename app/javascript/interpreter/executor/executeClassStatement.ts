import { Executor } from '../executor'
import * as Jiki from '../jikiObjects'
import {
  ClassStatement,
  ConstructorStatement,
  MethodStatement,
  PropertyStatement,
} from '../statement'
import { UserDefinedMethod } from '../functions'

export function executeClassStatement(
  executor: Executor,
  statement: ClassStatement
): void {
  executor.guardDefinedClass(statement.name)

  const klass = new Jiki.Class(statement.name.lexeme)

  statement.body.forEach((stmt) => {
    if (statement.type == 'ConstructorStatement') {
      executeConstructorStatement(executor, klass, stmt as ConstructorStatement)
    }
  })

  executor.addClass(klass)

  statement.body.forEach((stmt) => {
    if (stmt.type == 'ConstructorStatement') {
      executeConstructorStatement(executor, klass, stmt as ConstructorStatement)
    } else if (stmt.type == 'MethodStatement') {
      executeMethodStatement(executor, klass, stmt as MethodStatement)
    } else if (stmt.type == 'PropertyStatement') {
      executePropertyStatement(executor, klass, stmt as PropertyStatement)
    }
  })
}

function executeConstructorStatement(
  executor: Executor,
  klass: Jiki.Class,
  stmt: ConstructorStatement
) {
  const fn = new UserDefinedMethod(stmt)
  klass.addConstructor(fn)
}

function executeMethodStatement(
  executor: Executor,
  klass: Jiki.Class,
  stmt: MethodStatement
) {
  const fn = new UserDefinedMethod(stmt)
  const visibility = stmt.accessModifier.type == 'PUBLIC' ? 'public' : 'private'
  klass.addMethod(stmt.name.lexeme, null, visibility, fn)
}

function executePropertyStatement(
  executor: Executor,
  klass: Jiki.Class,
  stmt: PropertyStatement
): void {
  const visibility = stmt.accessModifier.type == 'PUBLIC' ? 'public' : 'private'
  klass.addProperty(stmt.name.lexeme)
  klass.addGetter(stmt.name.lexeme, visibility)
  klass.addSetter(stmt.name.lexeme, visibility)
}
