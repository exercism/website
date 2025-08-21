import { EditorView, WidgetType } from '@codemirror/view'

export class PlaceholderWidget extends WidgetType {
  constructor(readonly label: string, readonly mode: 'info' | 'tutorial') {
    super()
  }

  toDOM(_view: EditorView): HTMLElement {
    let wrap = document.createElement('span')
    wrap.className = `cm-placeholder-widget`
    wrap.classList.add(`${this.mode}Mode`)
    let tutorialEmoji = '\u{1f4ac}'
    wrap.innerText = `${this.mode === 'tutorial' ? tutorialEmoji : ''} ${
      this.label
    }`
    return wrap
  }
}

export class SVGWidget extends WidgetType {
  constructor(
    readonly arrowHeight: number,
    readonly right: number,
    readonly hoverRight: number,
    readonly declarationCoords: { bottom: number; right: number }
  ) {
    super()
  }

  toDOM(_view: EditorView): HTMLElement {
    const svgContainer = document.createElement('div')
    svgContainer.style.position = 'absolute'
    svgContainer.style.top = `${this.declarationCoords.bottom - 52}px`
    svgContainer.style.left = `${Math.min(
      this.hoverRight,
      this.declarationCoords.right
    )}px`
    svgContainer.innerHTML = generateArrowSVG(
      this.arrowHeight,
      this.right,
      this.hoverRight
    )
    return svgContainer
  }
}

export const placeholderTheme = EditorView.baseTheme({
  '.cm-placeholder-widget': {
    borderRadius: '8px',
    background: 'transparent',
    fontFamily: 'Poppins',
    padding: '2px 4px',
    color: '#76709F',
    fontSize: '14px',
    alignItems: 'center',
  },
  '.tutorialMode': {
    background: '#E1EBFF',
    color: '#2E57E8',
  },
})

export function placeholderExtension() {
  return [placeholderTheme]
}

function generateArrowSVG(length: number, right: number, hoverRight: number) {
  let offset = 30
  right = right + offset
  length = length + 10
  // startingPoint
  let s = { x: 5, y: 10 }
  let arrowWidth = 10
  let arrowLength = 14

  // topLeft
  let tl = `${s.x} ${s.y}`
  let tr = `${right} ${s.y}`
  let br = `${right} ${length}`
  let bl = `${hoverRight} ${length}`
  console.log('hover', hoverRight, 'right', right)
  return `
  <svg height="${length + 10}" width="${
    right + Math.abs(hoverRight - right)
  }" stroke-width="2" stroke="black">
    <path d="M${tl} L${s.x + arrowLength} ${s.y + arrowWidth / 2} L${
    s.x + arrowLength
  } ${s.y - arrowWidth / 2}Z M${tl} L${right - 10} ${s.y}Z M${right - 10} ${
    s.y
  } Q${tr}, ${right} ${s.y + 10}Z M${right} ${s.y + 10} L${br}Z" />
  <circle cx="${right}" cy="${length}" r="2" />
  </svg>
  `
}

;`
<svg width="13" height="108" viewBox="0 0 13 108" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M0.646447 3.64645C0.451184 3.84171 0.451184 4.15829 0.646447 4.35355L3.82843 7.53553C4.02369 7.7308 4.34027 7.7308 4.53553 7.53553C4.7308 7.34027 4.7308 7.02369 4.53553 6.82843L1.70711 4L4.53553 1.17157C4.7308 0.976311 4.7308 0.659728 4.53553 0.464466C4.34027 0.269204 4.02369 0.269204 3.82843 0.464466L0.646447 3.64645ZM1 106.5C0.723858 106.5 0.5 106.724 0.5 107C0.5 107.276 0.723858 107.5 1 107.5V106.5ZM11.5 8V103H12.5V8H11.5ZM8 106.5H1V107.5H8V106.5ZM1 4.5H6.5V3.5H1V4.5ZM6.5 4.5H8V3.5H6.5V4.5ZM11.5 103C11.5 104.933 9.933 106.5 8 106.5V107.5C10.4853 107.5 12.5 105.485 12.5 103H11.5ZM12.5 8C12.5 5.51472 10.4853 3.5 8 3.5V4.5C9.933 4.5 11.5 6.067 11.5 8H12.5Z" fill="black"/>
</svg>
`
