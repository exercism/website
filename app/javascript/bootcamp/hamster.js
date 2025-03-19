import Lottie from 'lottie-web'
import hamsterJSON from './lottiefiles/hamster.json'
import { animate } from '@juliangarnierorg/anime-beta'

const hamsterContainer = document.getElementById('hamster-animation-container')
const scrollingTestimonials = document.querySelector('.scrolling-testimonials')

const hamsterSpeed = { value: 1 }

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
    duration: 500,
    easing: 'linear',
    onUpdate() {
      Lottie.setSpeed(hamsterSpeed.value)
    },
  })
})

scrollingTestimonials.addEventListener('mouseout', () => {
  animate(hamsterSpeed, {
    value: 1,
    duration: 500,
    easing: 'linear',
    onUpdate() {
      Lottie.setSpeed(hamsterSpeed.value)
    },
  })
})
