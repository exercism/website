import { animate } from '@juliangarnierorg/anime-beta'
document.addEventListener('DOMContentLoaded', () => {
  const marqueeElement = document.querySelector('.scrolling-testimonials ul')
  const container = document.querySelector('.scrolling-testimonials')

  const computedStyle = getComputedStyle(container)
  const gap = parseFloat(computedStyle.getPropertyValue('--gap')) || 1

  const marqueeWidth = marqueeElement.scrollWidth

  const clonedItems = marqueeElement.innerHTML
  marqueeElement.innerHTML = clonedItems + clonedItems

  const speed = { current: 5, max: 20, min: 5 }
  let animationPosition = 0
  let lastTimestamp = null

  function animateMarquee(timestamp) {
    if (!lastTimestamp) {
      lastTimestamp = timestamp
    }

    const elapsed = timestamp - lastTimestamp
    lastTimestamp = timestamp

    animationPosition += elapsed * 0.03 * speed.current

    const totalWidth = marqueeWidth + gap

    if (animationPosition >= totalWidth) {
      animationPosition = animationPosition % totalWidth
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
