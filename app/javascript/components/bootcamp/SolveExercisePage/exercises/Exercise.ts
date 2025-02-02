import type { Animation } from '../AnimationTimeline/AnimationTimeline'
import type { ExternalFunction } from '@/interpreter/executor'
import { InterpretResult } from '@/interpreter/interpreter'
import { Statement } from '@/interpreter/statement'

export abstract class Exercise {
  public showAnimationsOnInfiniteLoops: boolean
  public availableFunctions!: ExternalFunction[]
  public animations: Animation[] = []
  public abstract getState(): any | null
  // allow dynamic method access
  [key: string]: any

  protected view!: HTMLElement
  protected container!: HTMLElement

  public constructor(private slug: String) {
    this.createView()
    this.showAnimationsOnInfiniteLoops = true
  }

  public wrapCode(code: string) {
    return code
  }

  public numberOfFunctionCallsInCode(
    interpreterResult: InterpretResult,
    fnName: string
  ) {
    return interpreterResult.callExpressions.filter(
      (expr) => expr.callee.name.lexeme == fnName
    ).length
  }

  public wasFunctionUsed(
    result: InterpretResult,
    name: string,
    args: any[] | null,
    times?: number
  ): boolean {
    let timesCalled
    const fnCalls = result.functionCallLog

    if (fnCalls[name] === undefined) {
      timesCalled = 0
    } else if (args !== null && args !== undefined) {
      timesCalled = fnCalls[name][JSON.stringify(args)]
    } else {
      timesCalled = Object.values(fnCalls[name]).reduce((acc, count) => {
        return acc + count
      }, 0)
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
