import { WidgetType } from '@codemirror/view'
import {
  computePosition,
  autoUpdate,
  arrow,
  offset,
  shift,
} from '@floating-ui/dom'
import hljs from 'highlight.js/lib/core'
import javascript from 'highlight.js/lib/languages/javascript'
import 'highlight.js/styles/default.min.css'

export class InformationWidget extends WidgetType {
  private tooltip: HTMLElement | null = null
  private referenceElement: HTMLElement | null = null
  private arrowElement: HTMLElement | null = null
  private observer: MutationObserver | null = null
  private autoUpdateCleanup: (() => void) | null = null
  private scrollContainer: HTMLElement | null = null

  constructor(
    private readonly tooltipHtml: string,
    private readonly status: 'ERROR' | 'SUCCESS'
  ) {
    super()
  }

  toDOM(): HTMLElement {
    this.referenceElement = this.createRefElement()
    this.createTooltip()
    this.createArrow()
    this.showTooltip()
    this.setupScrollListener()

    this.initializeObserver()

    return this.referenceElement
  }

  private createRefElement() {
    const refElement = document.createElement('span')
    refElement.classList.add('font-bold', 'text-black')
    refElement.style.float = 'right'
    refElement.innerText = ' '

    return refElement
  }

  private createTooltip() {
    this.tooltip = document.createElement('div')
    this.tooltip.classList.add('information-tooltip')
    if (this.status === 'ERROR') {
      this.tooltip.classList.add('error')
    } else {
      this.tooltip.classList.add('description')
    }
    this.tooltip.innerHTML = this.tooltipHtml
    document.body.appendChild(this.tooltip)

    this.applyHighlighting(this.tooltip)

    this.tooltip.style.opacity = '0'
  }

  private applyHighlighting(element: HTMLElement) {
    hljs.registerLanguage('javascript', javascript)
    const codeBlocks = element.querySelectorAll('pre code')
    codeBlocks.forEach((block) => {
      hljs.highlightBlock(block as HTMLElement)
    })
  }

  private createArrow() {
    if (!this.tooltip) return
    this.arrowElement = document.createElement('div')
    const arrowSize = '16px'
    this.arrowElement.style.width = arrowSize
    this.arrowElement.style.height = arrowSize
    this.arrowElement.classList.add('tooltip-arrow')
    this.arrowElement.style.position = 'absolute'
    this.tooltip.appendChild(this.arrowElement)
  }

  // @ts-ignore
  private setupListeners(refElement: HTMLElement | null = null) {
    if (!refElement) return
    refElement.addEventListener('mouseenter', () => this.showTooltip())
    refElement.addEventListener('mouseleave', () => this.hideTooltip())
  }

  private showTooltip() {
    if (!this.referenceElement || !this.tooltip || !this.arrowElement) return

    this.positionTooltip()

    if (this.referenceElement && this.tooltip) {
      this.autoUpdateCleanup = autoUpdate(
        this.referenceElement,
        this.tooltip,
        () => this.positionTooltip()
      )
    }
  }

  private positionTooltip() {
    if (!this.referenceElement || !this.tooltip || !this.arrowElement) return
    console.log('positioning')
    computePosition(this.referenceElement, this.tooltip, {
      placement: 'right',
      middleware: [
        offset(0),
        shift({ padding: 0 }),
        arrow({ element: this.arrowElement! }),
      ],
    }).then(({ x, y, middlewareData }) => {
      const { arrow } = middlewareData
      if (!this.tooltip) return
      Object.assign(this.tooltip.style, {
        left: `${x}px`,
        top: `${y}px`,
        opacity: '1',
        position: 'absolute',
      })

      Object.assign(this.arrowElement!.style, {
        left: `${-this.arrowElement!.offsetWidth / 2}px`,
        top: arrow?.y != null ? `${arrow.y}px` : '',
        transform: 'rotate(45deg)',
      })
    })
  }

  private hideTooltip() {
    if (this.tooltip) {
      this.tooltip.style.opacity = '0'
    }
  }

  // observe elements and remove tooltip if info icon ceases to exist
  private initializeObserver() {
    if (!this.referenceElement || !this.tooltip) return

    this.observer = new MutationObserver((mutationsList) => {
      for (const mutation of mutationsList) {
        if (mutation.type === 'childList') {
          mutation.removedNodes.forEach((node) => {
            if (node === this.referenceElement) {
              this.cleanup()
            }
          })
        }
      }
    })

    this.observer.observe(document.body, { childList: true, subtree: true })
  }

  private setupScrollListener() {
    const scrollContainer = document.querySelector('.cm-scroller')
    if (!scrollContainer) {
      return
    }
    scrollContainer.addEventListener('scroll', this.positionTooltip)
    this.scrollContainer = scrollContainer as HTMLElement
  }

  private cleanup() {
    if (this.scrollContainer) {
      this.scrollContainer.removeEventListener('scroll', this.positionTooltip)
    }

    if (this.autoUpdateCleanup) {
      this.autoUpdateCleanup()
      this.autoUpdateCleanup = null
    }

    if (this.tooltip && this.tooltip.parentNode) {
      this.tooltip.parentNode.removeChild(this.tooltip)
      this.tooltip = null
    }

    if (this.observer) {
      this.observer.disconnect()
      this.observer = null
    }
  }
}
