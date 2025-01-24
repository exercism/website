import { func } from 'prop-types'
import type { Animation } from '../AnimationTimeline/AnimationTimeline'
import type { ExecutionContext, ExternalFunction } from '@/interpreter/executor'
import { InterpretResult } from '@/interpreter/interpreter'
import { Statement } from '@/interpreter/statement'

export abstract class Exercise {
  public availableFunctions!: ExternalFunction[]
  public animations: Animation[] = []
  public abstract getState(): any | null
  // allow dynamic method access
  [key: string]: any

  protected view!: HTMLElement
  protected container!: HTMLElement
  protected functionCalls: Record<string, Record<any, number>> = {}

  public constructor(private slug: String) {
    this.createView()
  }

  public wrapCode(code: string) {
    return code
  }

  public recordFunctionUse(name: string, ...args) {
    this.functionCalls[name] ||= {}
    this.functionCalls[name][JSON.stringify(args)] ||= 0
    this.functionCalls[name][JSON.stringify(args)] += 1
  }

  public wasStatementUsed(
    result: InterpretResult,
    statementType: string
  ): boolean {
    return result.frames.some(
      (frame) => (frame.context as Statement).type == statementType
    )
  }

  public wasFunctionUsed(
    _: InterpretResult,
    name: string,
    args: any[] | null,
    times?: number
  ): boolean {
    let timesCalled

    if (this.functionCalls[name] === undefined) {
      timesCalled = 0
    } else if (args !== null && args !== undefined) {
      timesCalled = this.functionCalls[name][JSON.stringify(args)]
    } else {
      timesCalled = Object.values(this.functionCalls[name]).reduce(
        (acc, count) => {
          return acc + count
        },
        0
      )
    }

    if (times === null || times === undefined) {
      return timesCalled >= 1
    }
    return timesCalled === times
  }

  public lineNumberOffset = 0

  public addAnimation(animation: Animation) {
    this.animations.push(animation)
  }

  protected createView() {
    const cssClass = `exercise-${this.slug}`
    this.view = document.createElement('div')
    this.view.id = `${cssClass}-${Math.random().toString(36).substr(2, 9)}`
    this.view.classList.add('exercise-container')
    this.view.classList.add(cssClass)
    this.view.style.display = 'none'
    document.body.appendChild(this.view)
  }

  public getView(): HTMLElement {
    return this.view
  }
}
