import { EditorView, WidgetType } from '@codemirror/view'
import {
  computePosition,
  autoUpdate,
  arrow,
  offset,
  shift,
  Boundary,
} from '@floating-ui/dom'
import hljs from 'highlight.js/lib/core'
import javascript from 'highlight.js/lib/languages/javascript'
import 'highlight.js/styles/default.min.css'
import {
  addHighlight,
  removeAllHighlightEffect,
} from '../edit-editor/highlightRange'

export class InformationWidget extends WidgetType {
  private tooltip: HTMLElement | null = null
  private referenceElement: HTMLElement | null = null
  private arrowElement: HTMLElement | null = null
  private observer: MutationObserver | null = null
  private autoUpdateCleanup: (() => void) | null = null
  private scrollContainer: HTMLElement | null = null

  constructor(
    private readonly tooltipHtml: string,
    private readonly status: 'ERROR' | 'SUCCESS',
    private readonly view: EditorView
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
    // refElement.style.float = 'right'
    refElement.style.position = 'absolute'
    refElement.style.right = '0'
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

    const closeButton = document.createElement('button')
    closeButton.innerHTML = '&times;'
    closeButton.classList.add('tooltip-close')
    closeButton.onclick = () => this.hideTooltip()

    this.tooltip.querySelectorAll('code').forEach((ct) => {
      ct.addEventListener('mouseenter', () => {
        const from = ct.getAttribute('data-hl-from')
        const to = ct.getAttribute('data-hl-to')
        if (from && to) {
          this.view.dispatch({
            effects: addHighlight.of({
              from: Number(from) - 1,
              to: Number(to) - 1,
            }),
          })
        }
      })
      ct.addEventListener('mouseleave', () => {
        this.view.dispatch({ effects: removeAllHighlightEffect.of() })
      })
    })

    const errorHeader = this.tooltip.querySelector('.error h2')
    if (errorHeader) {
      errorHeader.appendChild(closeButton)
    }

    this.applyHighlighting(this.tooltip)

    this.tooltip.style.opacity = '0'
  }

  private hideTooltip() {
    if (this.tooltip) {
      this.tooltip.style.opacity = '0'
    }
  }

  private cleanupDuplicateTooltips() {
    const tooltips = document.querySelectorAll('.information-tooltip')

    if (tooltips.length > 1) {
      tooltips.forEach((tooltip, index) => {
        if (index < tooltips.length - 1) {
          tooltip.remove()
        }
      })
    }
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
    this.arrowElement.classList.add('tooltip-arrow')
    this.tooltip.prepend(this.arrowElement)
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
    const editor = document.getElementById('bootcamp-cm-editor')

    this.cleanupDuplicateTooltips()

    computePosition(this.referenceElement, this.tooltip, {
      placement: 'right',
      middleware: [
        offset(0),
        shift({ padding: 0, boundary: (editor as Boundary) ?? undefined }),
        arrow({ element: this.arrowElement! }),
      ],
    }).then(({ y, middlewareData }) => {
      const x = localStorage.getItem('solve-exercise-page-lhs')
      const { arrow } = middlewareData
      if (!this.tooltip) return
      Object.assign(this.tooltip.style, {
        left: `${x}px`,
        top: `${y}px`,
        opacity: '1',
        position: 'absolute',
      })

      let top = arrow?.y != null ? arrow.y : 0
      top = Math.max(top, 1)

      Object.assign(this.arrowElement!.style, {
        top: `${top}px`,
      })
    })
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

  private handleScroll?: EventListener
  private handleStorage?: (e: StorageEvent) => void

  private setupScrollListener() {
    const scrollContainer = document.querySelector('.cm-scroller')
    if (!scrollContainer) {
      return
    }

    this.handleScroll = this.positionTooltip.bind(this)
    this.handleStorage = (e: StorageEvent) => {
      if (e.key === 'solve-exercise-page-lhs') {
        this.positionTooltip()
      }
    }

    scrollContainer.addEventListener('scroll', this.handleScroll)
    window.addEventListener('storage', this.handleStorage)

    this.scrollContainer = scrollContainer as HTMLElement
  }

  private cleanup() {
    if (this.scrollContainer && this.handleScroll) {
      this.scrollContainer.removeEventListener('scroll', this.handleScroll)
    }

    if (this.handleStorage) {
      window.removeEventListener('storage', this.handleStorage)
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
