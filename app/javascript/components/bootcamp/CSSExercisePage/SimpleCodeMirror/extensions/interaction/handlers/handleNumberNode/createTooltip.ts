export function createTooltip(content: string): HTMLDivElement {
  const tooltip = document.createElement('div')
  tooltip.className = 'number-tooltip'
  Object.assign(tooltip.style, {
    position: 'absolute',
    top: '-18px',
    left: '50%',
    transform: 'translateX(-50%)',
    background: 'rgba(0, 0, 0, 0.7)',
    color: 'white',
    padding: '2px 6px',
    borderRadius: '3px',
    fontSize: '11px',
    pointerEvents: 'none',
    whiteSpace: 'nowrap',
  })
  tooltip.textContent = content
  return tooltip
}
