import { annotate } from 'rough-notation'
import { RoughAnnotationConfig } from 'rough-notation/lib/model'

export const annotateLanding = (): void => {
  window.addEventListener('load', () => {
    const h1 = document.querySelector<HTMLElement>('#page-landing h1 strong')

    if (h1) {
      const annotationH1 = annotate(h1, {
        type: 'highlight',
        color: '#FFF176',
        strokeWidth: 6,
        iterations: 1,
        multiline: true,
        animationDuration: 500,
        padding: 4,
      })

      setTimeout(function () {
        annotationH1.show()
      }, 1000)
    }

    const p = document.querySelector<HTMLElement>('#page-landing p strong')
    if (p) {
      const annotationP = annotate(p, {
        type: 'underline',
        color: '#3F3A5A',
        strokeWidth: 2,
        iterations: 1,
        padding: -4,
        multiline: true,
        animationDuration: 600,
      })

      setTimeout(function () {
        annotationP.show()
      }, 1800)
    }

    const headingUnderlineStyle: RoughAnnotationConfig = {
      type: 'underline',
      color: '#3F3A5A',
      strokeWidth: 4,
      iterations: 1,
      padding: -5,
      multiline: true,
    }

    const tracks = document.querySelector<HTMLElement>(
      '#page-landing .tracks-section h2 strong'
    )
    if (tracks) {
      const annotationTracks = annotate(tracks, headingUnderlineStyle)
      setTimeout(function () {
        annotationTracks.show()
      }, 1800)
    }

    const exercises = document.querySelector<HTMLElement>(
      '#page-landing .exercises-section h2 strong'
    )
    if (exercises) {
      const annotationExercises = annotate(exercises, headingUnderlineStyle)
      setTimeout(function () {
        annotationExercises.show()
      }, 1800)
    }

    const mentoring = document.querySelector<HTMLElement>(
      '#page-landing .mentoring-section h2 strong'
    )
    if (mentoring) {
      const annotationMentoring = annotate(mentoring, headingUnderlineStyle)
      setTimeout(function () {
        annotationMentoring.show()
      }, 1800)
    }
  })
}
