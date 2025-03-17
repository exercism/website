document.addEventListener('DOMContentLoaded', () => {
  const marqueeElement = document.querySelector('.scrolling-testimonials ul')
  const container = document.querySelector('.scrolling-testimonials')

  const computedStyle = getComputedStyle(container)
  const gap = parseFloat(computedStyle.getPropertyValue('--gap')) || 1

  const normalSpeed = 0.1
  const fastSpeed = 0.3
  let currentSpeed = normalSpeed
  let animationPosition = 0
  let lastTimestamp = null
  let isHovering = false

  function animateMarquee(timestamp) {
    if (!lastTimestamp) {
      lastTimestamp = timestamp
    }

    const elapsed = timestamp - lastTimestamp
    lastTimestamp = timestamp

    animationPosition += elapsed * 0.01 * currentSpeed

    if (animationPosition >= 100) {
      animationPosition = animationPosition % 100
    }

    marqueeElement.style.transform = `translateX(${-animationPosition}%)`

    requestAnimationFrame(animateMarquee)
  }

  requestAnimationFrame(animateMarquee)

  container.addEventListener('mouseenter', () => {
    isHovering = true

    const speedTransition = setInterval(() => {
      currentSpeed += 0.1
      if (currentSpeed >= fastSpeed) {
        currentSpeed = fastSpeed
        clearInterval(speedTransition)
      }
    }, 20)
  })

  container.addEventListener('mouseleave', () => {
    isHovering = false

    const speedTransition = setInterval(() => {
      currentSpeed -= 0.1
      if (currentSpeed <= normalSpeed) {
        currentSpeed = normalSpeed
        clearInterval(speedTransition)
      }
    }, 20)
  })
})
