// Copied from @exercism/active-background 0.6.2
// (https://github.com/exercism/react-active-background, MIT, Copyright (c) 2021
// Exercism) so the website no longer depends on that package. See
// ConfettiBackground.tsx for the component that draws it.
import { ConfettiPaper } from './ConfettiPaper'
import { ConfettiRibbon } from './ConfettiRibbon'

type ColorPair = [string, string]

export interface ConfettiOptions {
  speed?: number
  duration?: number
  confettiPaperCount?: number
  scaleConfettiCount?: boolean
  confettiRibbonCount?: number
  colorPairs?: ColorPair[]
}

const SPEED = 50
const DEFAULT_CONFETTI_PAPERS = 50
const DEFAULT_CONFETTI_RIBBONS = 10
const DEFAULT_SCALE_CONFETTI_COUNT = true

const COLORS: ColorPair[] = [
  ['#df0049', '#660671'],
  ['#00e857', '#005291'],
  ['#2bebbc', '#05798a'],
  ['#ffd200', '#b06c00'],
]

export class Confetti {
  private readonly canvas: HTMLCanvasElement
  private readonly context: CanvasRenderingContext2D | null

  private readonly ratio: number
  public readonly width: number
  public readonly height: number

  private readonly speed: number
  private readonly duration: number
  private readonly confettiPapers: ConfettiPaper[]
  private readonly confettiRibbons: ConfettiRibbon[]
  private readonly colorPairs: ColorPair[]

  private animationFrameRequestId: number | null

  constructor(canvas: HTMLCanvasElement, options: ConfettiOptions = {}) {
    this.canvas = canvas
    this.context = canvas.getContext('2d')

    this.speed = options?.speed ?? SPEED
    this.duration = options?.duration ?? 1.0 / this.speed

    this.ratio = window.devicePixelRatio
    this.width = canvas.offsetWidth * this.ratio
    this.height = canvas.offsetHeight * this.ratio

    this.colorPairs = options?.colorPairs ?? COLORS

    let confettiPaperCount =
      options?.confettiPaperCount ?? DEFAULT_CONFETTI_PAPERS

    if (options?.scaleConfettiCount ?? DEFAULT_SCALE_CONFETTI_COUNT) {
      confettiPaperCount = Math.round(confettiPaperCount / this.ratio)
    }

    const getRandomColorPair = getRandomColors(this.colorPairs)

    this.confettiPapers = [...new Array(confettiPaperCount)].map(() => {
      return new ConfettiPaper({
        parent: this,
        fetchColors: getRandomColorPair,
      })
    })

    let confettiRibbonCount =
      options?.confettiRibbonCount ?? DEFAULT_CONFETTI_RIBBONS

    this.confettiRibbons = [...new Array(confettiRibbonCount)].map(() => {
      return new ConfettiRibbon({
        parent: this,
        fetchColors: getRandomColorPair,
      })
    })

    this.animationFrameRequestId = null
  }

  public start(): void {
    this.animationFrameRequestId = requestAnimationFrame(this.render.bind(this))
  }

  public stop(): void {
    if (this.animationFrameRequestId) {
      cancelAnimationFrame(this.animationFrameRequestId)
    }
  }

  public render(): void {
    if (!this.context) {
      return
    }

    this.context.clearRect(0, 0, this.canvas.width, this.canvas.height)

    for (const confettiPaper of this.confettiPapers) {
      confettiPaper.update(this.duration)
      confettiPaper.draw(this.context)
    }

    for (const confettiRibbon of this.confettiRibbons) {
      confettiRibbon.update(this.duration)
      confettiRibbon.draw(this.context)
    }

    this.animationFrameRequestId = requestAnimationFrame(this.render.bind(this))
  }
}

function getRandomColors(colors: ColorPair[] = COLORS): () => ColorPair {
  return function () {
    const randomIndex = Math.round(Math.random() * (colors.length - 1))
    return colors[randomIndex]
  }
}
