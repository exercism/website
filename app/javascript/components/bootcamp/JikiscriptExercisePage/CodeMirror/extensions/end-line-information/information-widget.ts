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
import setupJikiscript from '@exercism/highlightjs-jikiscript'
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

  constructor(
    private readonly tooltipHtml: string,
    private readonly status: 'ERROR' | 'SUCCESS',
    private readonly view: EditorView,
    private readonly onClose: (view: EditorView) => void
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
    refElement.style.position = 'absolute'
    refElement.style.right = '0'
    refElement.innerText = ' '

    return refElement
  }

  private createTooltip() {
    this.tooltip = document.createElement('div')
    this.tooltip.classList.add('information-tooltip')
    const content = document.createElement('div')
    content.classList.add('content')
    content.innerHTML = this.tooltipHtml
    this.tooltip.appendChild(content)

    if (this.status === 'ERROR') {
      this.tooltip.classList.add('error')
    } else {
      this.tooltip.classList.add('description')
    }
    document.body.appendChild(this.tooltip)

    const closeButton = document.createElement('button')
    closeButton.innerHTML = '&times;'
    closeButton.classList.add('tooltip-close')
    closeButton.onclick = () => {
      this.onClose(this.view)
    }

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

    const header = (this.tooltip.querySelector('.error h2') ||
      this.tooltip.querySelector('h3')) as HTMLHeadingElement

    if (header) {
      header.prepend(closeButton)

      if (header.tagName === 'H3') {
        Object.assign(header.style, {
          display: 'flex',
          flexDirection: 'row-reverse',
          justifyContent: 'space-between',
        })
      }
    }

    this.applyHighlighting(this.tooltip)

    this.tooltip.style.opacity = '0'
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
    hljs.registerLanguage('jikiscript', setupJikiscript)
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
    // this gets the actual editor, instead of querySelecting it
    // useful if there are multiple editors on one page
    const editor = this.view.dom

    this.cleanupDuplicateTooltips()

    computePosition(this.referenceElement, this.tooltip, {
      placement: 'right',
      middleware: [
        offset(0),
        shift({ padding: 0, boundary: (editor as Boundary) ?? undefined }),
        arrow({ element: this.arrowElement! }),
      ],
    }).then(({ y, middlewareData }) => {
      // attach to actual editor's right side instead of a random external store value - like panel's location
      const editorRect = editor.getBoundingClientRect()
      const x = editorRect.right + 10
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
  private scrollContainers: HTMLElement[] = []

  private setupScrollListener() {
    const scrollContainers = document.querySelectorAll('.cm-scroller')
    if (!scrollContainers) return

    this.handleScroll = this.positionTooltip.bind(this)
    this.handleStorage = (e: StorageEvent) => {
      if (
        e.key === 'solve-exercise-page-lhs' ||
        e.key === 'frontend-training-page-size'
      ) {
        this.positionTooltip()
      }
    }

    this.scrollContainers = []

    for (const scrollContainer of scrollContainers) {
      if (scrollContainer instanceof HTMLElement) {
        scrollContainer.addEventListener('scroll', this.handleScroll)
        this.scrollContainers.push(scrollContainer)
      }
    }

    window.addEventListener('storage', this.handleStorage)
  }

  private cleanup() {
    if (this.handleScroll) {
      for (const container of this.scrollContainers) {
        container.removeEventListener('scroll', this.handleScroll)
      }
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

    this.scrollContainers = []
  }
}
