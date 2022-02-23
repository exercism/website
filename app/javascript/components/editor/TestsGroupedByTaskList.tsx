import React, { useContext } from 'react'
import { TestStatus, Test, AssignmentTask } from './types'
import { GraphicalIcon } from '../common/GraphicalIcon'
import { TestsGroup, TestWithToggle } from './TestsGroup'
import { TestSummary } from './TestSummary'
import { TasksContext } from '../Editor'

type TaskWithTestsWithToggle = AssignmentTask & {
  id: number
  tests: TestWithToggle[]
  defaultOpen: boolean
  passing: boolean
}

const Tests = ({
  tests,
  language,
}: {
  tests: TestWithToggle[]
  language: string
}): JSX.Element => {
  return (
    <>
      {tests.map((test, i) => (
        <TestSummary
          key={i}
          test={test}
          defaultOpen={test.defaultOpen}
          language={language}
        />
      ))}
    </>
  )
}

const Title = ({ task }: { task: TaskWithTestsWithToggle }): JSX.Element => {
  return (
    <>
      <span>Task {task.id}</span> <span>{task.title}</span>
    </>
  )
}

const JumpToInstructionButton = ({
  taskId,
}: {
  taskId: number
}): JSX.Element | null => {
  const { switchToTask, showJumpToInstructionButton } = useContext(TasksContext)

  return showJumpToInstructionButton ? (
    <button type="button" onClick={() => switchToTask(taskId)}>
      Jump to Instruction
    </button>
  ) : null
}

export function TestsGroupedByTaskList({
  tests,
  language,
  tasks,
}: {
  tests: Test[]
  language: string
  tasks: AssignmentTask[]
}): JSX.Element {
  const testsWithIndex = tests.map((test, i) => ({ index: i + 1, ...test }))
  const tasksWithTests = tasks
    .map((task, i) => ({
      ...task,
      id: i + 1,
      tests: testsWithIndex.filter((test) => test.taskId === i + 1),
    }))
    .map((task) => ({
      ...task,
      passing: task.tests.every((test) => test.status === TestStatus.PASS),
    }))

  const openTaskIdx = tasksWithTests.findIndex((t) => !t.passing)

  const tasksWithTestsWithToggle: TaskWithTestsWithToggle[] =
    tasksWithTests.map((task, i) => ({
      ...task,
      defaultOpen: i === openTaskIdx,
      tests: task.tests.map((test, j) => ({
        ...test,
        defaultOpen:
          i === openTaskIdx &&
          j ==
            task.tests.findIndex(
              (test) =>
                test.status === TestStatus.FAIL ||
                test.status === TestStatus.ERROR
            ),
      })),
    }))

  return (
    <div className="tests-list">
      {tasksWithTestsWithToggle.map((task, i) => (
        <TestsGroup key={i} tests={task.tests} open={task.defaultOpen}>
          <TestsGroup.Header>
            <GraphicalIcon
              icon={
                task.passing ? 'passed-check-circle' : 'failed-check-circle'
              }
              className="indicator"
            />
            <Title task={task} />
            <GraphicalIcon icon="chevron-right" className="--closed-icon" />
            <GraphicalIcon icon="chevron-down" className="--open-icon" />
          </TestsGroup.Header>
          <Tests tests={task.tests} language={language} />
          <JumpToInstructionButton taskId={task.id} />
        </TestsGroup>
      ))}
    </div>
  )
}
