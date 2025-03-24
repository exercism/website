import { animate } from '@juliangarnierorg/anime-beta'
document.addEventListener('DOMContentLoaded', () => {
  const marqueeElement = document.querySelector('.scrolling-testimonials ul')
  const container = document.querySelector('.scrolling-testimonials')

  const marqueeWidth = marqueeElement.scrollWidth

  const clonedItems = marqueeElement.innerHTML
  marqueeElement.innerHTML = clonedItems + clonedItems

  const speed = { current: 1, max: 5, min: 1 }
  // this slows the animation down, if we need a slower/faster speed, adjust this value accordingly
  // and keep the speed.min and speed.max values as ratio numbers
  const velocityScale = 0.1
  let animationPosition = 0
  let lastTimestamp = null

  function animateMarquee(timestamp) {
    if (!lastTimestamp) {
      lastTimestamp = timestamp
    }

    const elapsed = timestamp - lastTimestamp
    lastTimestamp = timestamp

    animationPosition += elapsed * speed.current * velocityScale

    if (animationPosition >= marqueeWidth) {
      animationPosition = animationPosition % marqueeWidth
    }

    marqueeElement.style.transform = `translateX(${-animationPosition}px)`

    requestAnimationFrame(animateMarquee)
  }

  requestAnimationFrame(animateMarquee)

  container.addEventListener('mouseenter', () => {
    animate(speed, {
      current: speed.max,
      duration: 500,
      easing: 'linear',
    })
  })

  container.addEventListener('mouseleave', () => {
    animate(speed, {
      current: speed.min,
      duration: 500,
      easing: 'linear',
    })
  })
})
