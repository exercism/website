import { File } from '@/components/types'

export type CodeTaggerProps = {
  code: CodeTaggerCode
  tags: Tags
  links: {
    confirmTagsApi: string
    trainingDataDashboard: string
    nextTaggableCodeLink: string
  }
  allTags: Tags
}

export type CodeTaggerCode = {
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
}

export type Tags = string[]

export type CodeTaggerConfirmTagsAPIResponse = {
  nextExerciseLink: string
}
