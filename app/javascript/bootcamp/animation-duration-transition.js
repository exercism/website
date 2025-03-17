import { animate } from '@juliangarnierorg/anime-beta'

const scrollingTestimonials = document.querySelector('.scrolling-testimonials')
const ul = scrollingTestimonials.querySelector('ul')

if (ul) {
  const scroll = { durationTime: 60 }

  ul.addEventListener('mouseenter', () => {
    console.log('entering mouse')
    animate(scroll, {
      durationTime: 20,
      duration: 1000,
      loop: false,
      ease: 'linear',
      onUpdate: () => {
        console.log('duration', scroll)
        ul.style.animation = `${scroll.durationTime}s`
      },
    })
  })
  ul.addEventListener('mouseleave', () => {
    console.log('entering mouse')
    animate(scroll, {
      durationTime: 60,
      duration: 1000,
      loop: false,
      ease: 'linear',
      onUpdate: () => {
        console.log('duration', scroll)
        ul.style.animationDuration = `${scroll.durationTime}s`
      },
    })
  })
}
