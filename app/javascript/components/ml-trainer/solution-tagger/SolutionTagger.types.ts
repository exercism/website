import { File } from '@/components/types'

export type SolutionTaggerProps = {
  solution: SolutionTaggerSolution
  tags: Tags
  links: {
    confirmTagsEndpoint: string
  }
}

export type SolutionTaggerSolution = {
  track: {
    title: string
    iconUrl: string
    highlightjsLanguage: string
  }
  exercise: {
    title: string
    iconUrl: string
  }

  files: readonly File[]
  language: string
}

export type Tags = string[]

export type SolutionTaggerConfirmTagsAPIResponse = {
  nextExerciseLink: string
}
