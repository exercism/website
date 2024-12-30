import type { Animation } from '../AnimationTimeline/AnimationTimeline'
import type { ExternalFunction } from '@/interpreter/executor'

export abstract class Exercise {
  public availableFunctions!: ExternalFunction[]
  public animations: Animation[] = []
  public abstract getState(): any | null
  // allow dynamic method access
  [key: string]: any

  protected view!: HTMLElement
  protected container!: HTMLElement

  public constructor(private slug: String) {
    this.createView()
  }

  public wrapCode(code: string) {
    return code
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
