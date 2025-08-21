import confetti from 'canvas-confetti'

let confettiCanvas: HTMLCanvasElement | null = null
let myConfetti: any

function setupCanvas() {
  if (!confettiCanvas) {
    confettiCanvas = document.createElement('canvas')
    Object.assign(confettiCanvas.style, {
      position: 'fixed',
      top: '0',
      left: '0',
      width: '100%',
      height: '100%',
      pointerEvents: 'none',
      zIndex: '9999',
    })

    document.body.appendChild(confettiCanvas)

    myConfetti = confetti.create(confettiCanvas, { resize: true })
  }
}

export function launchConfetti() {
  setupCanvas()

  const duration = 300
  const end = Date.now() + duration
  const colors = ['#FE3C00', '#AFC8F3', '#4C2E55', '#E9DE3F', '#BEEEAB']

  function createConfetti(originX: number) {
    myConfetti({
      particleCount: 7,
      angle: originX === 0 ? 60 : 120,
      spread: 50,
      origin: { x: originX, y: 1 },
      colors: colors,
    })
  }

  ;(function frame() {
    createConfetti(0)
    createConfetti(1)

    if (Date.now() < end) {
      requestAnimationFrame(frame)
    }
  })()
}

export function cleanupCanvas() {
  if (confettiCanvas) {
    document.body.removeChild(confettiCanvas)
    confettiCanvas = null
    myConfetti = null
  }
}
