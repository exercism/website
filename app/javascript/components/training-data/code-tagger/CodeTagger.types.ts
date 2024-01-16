import { File } from '@/components/types'
import { TrainingDataStatus } from '../dashboard/Dashboard.types'

export type CodeTaggerProps = {
  code: CodeTaggerCode
  sample: {
    tags: Tags
    status: TrainingDataStatus
  }
  links: {
    confirmTagsApi: string
    trainingDataDashboard: string
    nextSample: string
  }
}

export type CodeTaggerCode = {
  track: {
    title: string
    iconUrl: string
    highlightjsLanguage: string
    tags: Tags
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
