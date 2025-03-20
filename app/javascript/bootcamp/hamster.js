import Lottie from 'lottie-web'
import hamsterJSON from './lottiefiles/hamster.json'
import { animate } from '@juliangarnierorg/anime-beta'

(() => {
  const hamsterContainer = document.getElementById('hamster-animation-container')
  const scrollingTestimonials = document.querySelector('.scrolling-testimonials')
  if(scrollingTestimonials === null) return

  const hamsterSpeed = { value: 1 }
  const TRANSITION_DURATION = 500

  Lottie.loadAnimation({
    container: hamsterContainer,
    renderer: 'svg',
    loop: true,
    autoplay: true,
    animationData: hamsterJSON,
  })

  scrollingTestimonials.addEventListener('mouseover', () => {
    animate(hamsterSpeed, {
      value: 3,
      duration: TRANSITION_DURATION,
      easing: 'linear',
      onUpdate() {
        Lottie.setSpeed(hamsterSpeed.value)
      },
    })
  })

  scrollingTestimonials.addEventListener('mouseout', () => {
    animate(hamsterSpeed, {
      value: 1,
      duration: TRANSITION_DURATION,
      easing: 'linear',
      onUpdate() {
        Lottie.setSpeed(hamsterSpeed.value)
      },
    })
  })
})()