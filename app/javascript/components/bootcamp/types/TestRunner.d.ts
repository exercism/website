import { CustomFunction, EvaluationContext } from '@/interpreter/interpreter'

declare type TestRunnerOptions = {
  studentCode: string
  tasks: Task[]
  config: Exercise['config']
  customFunctions: CustomFunction[]
}
