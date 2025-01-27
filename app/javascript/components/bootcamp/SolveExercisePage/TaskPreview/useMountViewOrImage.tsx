import { useRef, useEffect, useMemo } from 'react'
import { getAndInitializeExerciseClass } from '../utils/exerciseMap'

export function useMountViewOrImage({
  config,
  taskTest,
  testSuiteResult,
}: {
  config: Config
  taskTest: TaskTest
  testSuiteResult: TestSuiteResult<any> | null
}) {
  if (!taskTest) return

  const exercise = useMemo(
    () => getAndInitializeExerciseClass(config),
    [config]
  )
  if (!exercise) return
  ;(taskTest.setupFunctions || []).forEach((functionData) => {
    let [functionName, params] = functionData
    if (!params) {
      params = []
    }
    if (!exercise) return
    exercise[functionName](...params)
  })

  const viewContainerRef = useRef<HTMLDivElement | null>(null)

  useEffect(() => {
    if (!viewContainerRef.current) return
    if (exercise && exercise.getView()) {
      const view = exercise.getView()

      if (viewContainerRef.current.children.length > 0) {
        const oldView = viewContainerRef.current.children[0] as HTMLElement
        document.body.appendChild(oldView)
        oldView.style.display = 'none'
      }

      // on each result change, clear out view-container
      viewContainerRef.current.innerHTML = ''
      viewContainerRef.current.appendChild(view)
      view.style.display = 'block'
    } else {
      let img
      if (viewContainerRef.current.children.length > 0) {
        img = viewContainerRef.current.children[0] as HTMLElement
      } else {
        img = document.createElement('div')
        Object.assign(img.style, {
          width: '100%',
          height: '100%',
          backgroundSize: '90%',
          backgroundRepeat: 'no-repeat',
          backgroundColor: 'white',
          backgroundPosition: 'center',
        })
        viewContainerRef.current.appendChild(img)
      }
      img.style.backgroundImage = `url('/exercise-images/${
        taskTest.imageSlug ?? 'rock-paper-scissors/paper-paper.png'
      }')`

      const viewDisplay = taskTest.imageSlug === undefined ? 'none' : 'block'
      viewContainerRef.current.style.display = viewDisplay
    }
  }, [testSuiteResult])

  return viewContainerRef
}
