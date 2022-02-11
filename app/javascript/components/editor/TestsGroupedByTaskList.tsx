import React, { useContext } from 'react'
import { TestStatus, Test, AssignmentTask } from './types'
import { GraphicalIcon } from '../common/GraphicalIcon'
import { TestsGroup, TestWithToggle } from './TestsGroup'
import { TestSummary } from './TestSummary'
import { TasksContext } from '../Editor'

type TaskWithTestsWithToggle = AssignmentTask & {
  id: number
  tests: TestWithToggle[]
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
      {tests.map((test) => (
        <TestSummary
          key={test.name}
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
}): JSX.Element => {
  const { switchToTask } = useContext(TasksContext)

  return (
    <button type="button" onClick={() => switchToTask(taskId)}>
      Jump to Instruction
    </button>
  )
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
  const tasksWithTests = tasks.map((task, i) => ({
    ...task,
    id: i + 1,
    tests: testsWithIndex.filter((test) => test.taskId === i + 1),
  }))
  const passed: TaskWithTestsWithToggle[] = tasksWithTests
    .filter((task) =>
      task.tests.every((test) => test.status === TestStatus.PASS)
    )
    .map((task) => ({
      ...task,
      tests: task.tests.map((test) => {
        return { ...test, defaultOpen: false }
      }),
    }))

  const failed: TaskWithTestsWithToggle[] = tasksWithTests
    .filter((task) =>
      task.tests.some(
        (test) =>
          test.status === TestStatus.FAIL || test.status === TestStatus.ERROR
      )
    )
    .map((task, i) => ({
      ...task,
      tests: task.tests.map((test, j) => {
        return {
          ...test,
          defaultOpen:
            i === 0 &&
            j ==
              task.tests.findIndex(
                (test) =>
                  test.status === TestStatus.FAIL ||
                  test.status === TestStatus.ERROR
              ),
        }
      }),
    }))

  return (
    <div className="tests-list">
      {passed.map((task) => (
        <TestsGroup key={task.id} tests={task.tests} open={false}>
          <TestsGroup.Header>
            <GraphicalIcon icon="passed-check-circle" className="indicator" />
            <Title task={task} />
            <GraphicalIcon icon="chevron-right" className="--closed-icon" />
            <GraphicalIcon icon="chevron-down" className="--open-icon" />
          </TestsGroup.Header>
          <Tests tests={task.tests} language={language} />
          <JumpToInstructionButton taskId={task.id} />
        </TestsGroup>
      ))}

      {failed.map((task, i) => (
        <TestsGroup key={task.id} tests={task.tests} open={i === 0}>
          <TestsGroup.Header>
            <GraphicalIcon icon="failed-check-circle" className="indicator" />
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
