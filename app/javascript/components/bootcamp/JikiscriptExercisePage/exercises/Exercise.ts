import type { Animation } from '../AnimationTimeline/AnimationTimeline'
import type { ExecutionContext, ExternalFunction } from '@/interpreter/executor'
import { InterpretResult } from '@/interpreter/interpreter'
import checkers from '../test-runner/generateAndRunTestSuite/checkers'

export abstract class Exercise {
  public showAnimationsOnInfiniteLoops: boolean
  public availableFunctions!: ExternalFunction[]
  public animations: Animation[] = []
  public abstract getState(): any | null
  // allow dynamic method access
  [key: string]: any

  protected view!: HTMLElement
  protected container!: HTMLElement
  public static hasView = true

  public constructor(private slug?: String) {
    if (slug) {
      this.createView()
    }
    this.showAnimationsOnInfiniteLoops = true
  }

  public wrapCode(code: string) {
    return code
  }

  public numFunctionCalls(
    result: InterpretResult,
    name: string,
    args: any[] | null,
    times?: number
  ): number {
    return checkers.numFunctionCalls(result, name, args, times)
  }

  public wasFunctionCalled(
    result: InterpretResult,
    name: string,
    args: any[] | null,
    times?: number
  ): boolean {
    return checkers.wasFunctionCalled(result, name, args, times)
  }

  public numFunctionCallsInCode(
    result: InterpretResult,
    fnName: string
  ): number {
    return checkers.numFunctionCallsInCode(result, fnName)
  }

  public numStatements(result: InterpretResult): number {
    return checkers.numStatements(result)
  }

  public numTimesStatementUsed(result: InterpretResult, type: string): number {
    return checkers.numTimesStatementUsed(result, type)
  }

  public numLinesOfCode(
    result: InterpretResult,
    numStubLines: number = 0
  ): number {
    return checkers.numLinesOfCode(result, numStubLines)
  }

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

  public animateIntoView(
    executionCtx: ExecutionContext,
    targets: string,
    options = { duration: 1, offset: 0 }
  ) {
    this.addAnimation({
      targets,
      duration: options.duration,
      transformations: {
        opacity: 1,
      },
      offset: executionCtx.getCurrentTime() + options.offset,
    })
    executionCtx.fastForward(1)
  }

  public animateOutOfView(
    executionCtx: ExecutionContext,
    targets: string,
    options = { duration: 1, offset: 0 }
  ) {
    this.addAnimation({
      targets,
      duration: options.duration,
      transformations: {
        opacity: 0,
      },
      offset: executionCtx.getCurrentTime() + options.offset,
    })
    executionCtx.fastForward(1)
  }

  protected fireFireworks(_: ExecutionContext, startTime: number) {
    const fireworks = document.createElement('div')
    fireworks.classList.add('fireworks')
    fireworks.style.opacity = '0'
    fireworks.innerHTML = `
      <div class="before"></div>
      <div class="after"></div>
    `
    this.view.appendChild(fireworks)

    this.addAnimation({
      targets: `#${this.view.id} .fireworks`,
      duration: 1,
      transformations: {
        opacity: 1,
      },
      offset: startTime,
    })
    this.addAnimation({
      targets: `#${this.view.id} .fireworks`,
      duration: 1,
      transformations: {
        opacity: 0,
      },
      offset: startTime + 2500,
    })
  }
}
