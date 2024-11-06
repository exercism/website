import confetti from 'canvas-confetti'

const linkedin = document.querySelector('.linkedin')

const observer = new IntersectionObserver(([linkedin], observer) => {
  if (linkedin.isIntersecting) {
    launchConfetti()
    observer.disconnect()
  }
})

if (linkedin) observer.observe(linkedin)

/* ========================= helpers & setup ========================= */
function createCanvas() {
  const confettiCanvas = document.createElement('canvas')
  confettiCanvas.style.position = 'fixed'
  confettiCanvas.style.top = 0
  confettiCanvas.style.left = 0
  confettiCanvas.style.width = '100%'
  confettiCanvas.style.height = '100%'
  confettiCanvas.style.pointerEvents = 'none'
  confettiCanvas.style.zIndex = '9999'
  document.body.appendChild(confettiCanvas)
  return confettiCanvas
}

const confettiCanvas = createCanvas()
const myConfetti = confetti.create(confettiCanvas, { resize: true })
function launchConfetti() {
  const duration = 300 // in ms
  const end = Date.now() + duration
  const colors = ['#FE3C00', '#AFC8F3', '#4C2E55', '#E9DE3F', '#BEEEAB']

  function createConfetti(originX) {
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
