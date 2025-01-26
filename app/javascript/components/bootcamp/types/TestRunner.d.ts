import { EvaluationContext } from '@/interpreter/interpreter'

declare type TestRunnerOptions = {
  studentCode: string
  tasks: Task[]
  config: Exercise['config']
}
