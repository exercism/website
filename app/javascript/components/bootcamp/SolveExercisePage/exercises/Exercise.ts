import { func } from 'prop-types'
import type { Animation } from '../AnimationTimeline/AnimationTimeline'
import type { ExecutionContext, ExternalFunction } from '@/interpreter/executor'
import { InterpretResult } from '@/interpreter/interpreter'

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

  public wasFunctionUsed(
    _: ExecutionContext | InterpretResult,
    name: string,
    args: any[] | null,
    times?: number
  ): boolean {
    let timesCalled

    console.log('HERE')
    console.log(name)
    console.log(this.functionCalls)
    if (this.functionCalls[name] === undefined) {
      console.log('HER1')
      timesCalled = 0
    } else if (args !== null && args !== undefined) {
      console.log('HER2')
      console.log(JSON.stringify(args))
      timesCalled = this.functionCalls[name][JSON.stringify(args)]
    } else {
      console.log('HER3')
      timesCalled = Object.values(this.functionCalls[name]).reduce(
        (acc, count) => {
          return acc + count
        },
        0
      )
    }
    console.log(timesCalled)

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

    this.container = document.createElement('div')
    this.view.appendChild(this.container)
  }

  public getView(): HTMLElement {
    return this.view
  }
}
