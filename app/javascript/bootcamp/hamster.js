import Lottie from 'lottie-web'
import hamsterJSON from './lottiefiles/hamster.json'
import { animate } from '@juliangarnierorg/anime-beta'

function initHamsterAnimation() {
  let hamsterAnimation = null
  let smokeTimeout = null
  let smokeInterval = null
  const hamsterSpeed = { value: 1 }

  const TRANSITION_DURATION = 500
  const SMOKE_DELAY = 200
  const SMOKE_INTERVAL = 50

  const hamsterContainer = document.getElementById(
    'hamster-animation-container'
  )
  const scrollingTestimonials = document.querySelector(
    '.scrolling-testimonials'
  )
  const smokeContainer = document.getElementById('smoke-container')

  if (!hamsterContainer || !scrollingTestimonials || !smokeContainer) {
    console.error('element not found')
    return
  }

  Object.assign(smokeContainer.style, {
    position: 'absolute',
    right: '55px',
    top: '-200px',
    width: '100px',
    height: '150px',
    margin: '50px auto',
    overflow: 'visible',
    pointerEvents: 'none',
  })

  hamsterAnimation = Lottie.loadAnimation({
    container: hamsterContainer,
    renderer: 'svg',
    loop: true,
    autoplay: true,
    animationData: hamsterJSON,
  })

  const clearTimers = () => {
    if (smokeTimeout) {
      clearTimeout(smokeTimeout)
      smokeTimeout = null
    }
    if (smokeInterval) {
      clearInterval(smokeInterval)
      smokeInterval = null
    }
  }

  const createPuff = () => {
    const puff = document.createElement('div')

    const finalScale = (1.5 + Math.random() * 3).toFixed(2)
    const finalX = -350 - Math.random() * 100
    const finalY = -90 - Math.random() * 30
    const duration = (1.8 + Math.random() * 0.6).toFixed(2)
    const durationMs = parseFloat(duration) * 1000

    Object.assign(puff.style, {
      position: 'absolute',
      bottom: '0',
      left: '50%',
      width: '30px',
      height: '30px',
      background:
        'radial-gradient(circle, rgba(238,238,238,0.8) 0%, rgba(170,170,170,0.5) 100%)',
      borderRadius: '50%',
      opacity: '0',
      transform: 'translateX(-50%)',
      pointerEvents: 'none',
    })

    puff.animate(
      [
        { opacity: 0, transform: 'translate(-50%, 0) scale(0.5)' },
        { offset: 0.1, opacity: 0.2 },
        {
          opacity: 0,
          transform: `translate(${finalX}%, ${finalY}px) scale(${finalScale})`,
        },
      ],
      { duration: durationMs, easing: 'ease-out', fill: 'forwards' }
    )

    smokeContainer.appendChild(puff)
    setTimeout(() => puff.remove(), durationMs)
  }

  const startSmokeMachine = () => setInterval(createPuff, SMOKE_INTERVAL)

  const handleMouseEnter = () => {
    animate(hamsterSpeed, {
      value: 3,
      duration: TRANSITION_DURATION,
      easing: 'linear',
      onUpdate() {
        Lottie.setSpeed(hamsterSpeed.value)
      },
    })

    smokeTimeout = setTimeout(() => {
      smokeInterval = startSmokeMachine()
    }, SMOKE_DELAY)
  }

  const handleMouseLeave = () => {
    animate(hamsterSpeed, {
      value: 1,
      duration: TRANSITION_DURATION,
      easing: 'linear',
      onUpdate() {
        Lottie.setSpeed(hamsterSpeed.value)
      },
    })

    clearTimers()
  }

  scrollingTestimonials.addEventListener('mouseenter', handleMouseEnter)
  scrollingTestimonials.addEventListener('mouseleave', handleMouseLeave)
}

document.addEventListener('DOMContentLoaded', initHamsterAnimation)
