import { AnimationTimeline } from '../AnimationTimeline/AnimationTimeline'
import DrawExercise from '../exercises/draw/DrawExercise'
import { interpret } from '@/interpreter/interpreter'
import { describe } from '../test-runner'
import { expect } from '../test-runner/expect'

/*
  DON'T DELETE THIS YET
 */
export default (options: TestRunnerOptions) =>
  describe('drawing tests', options, (test) => {
    test('draws at least 5 rectangles', () => {
      const drawE = new DrawExercise('draws-at-least-5-rectangles')

      /* store the generated view in this variable to prevent it from being permanently deleted 
      when switching between test results -- which clears out the view container */
      const view = document.getElementById('draws-at-least-5-rectangles')
      const mountView = drawE.mount
      const evaluated = interpret(options.studentCode, {
        externalFunctions: drawE.availableFunctions,
        state: { elementSerial: 0 },
        language: 'JikiScript',
      })

      const { frames, state } = evaluated
      const actual = state.elementSerial

      const { animations } = drawE
      const animationTimeline = new AnimationTimeline(
        {},
        frames
      ).populateTimeline(animations)

      const expected = 5
      return {
        expectCb: expect(actual).toBeGreaterThanOrEqual(expected),
        codeRun: '',
        frames,
        view,
        animationTimeline: animationTimeline,
        mountView,
      }
    })

    test('draws no more than 8 rectangles', () => {
      const drawE = new DrawExercise('draws-no-more-than-8-rectangles')

      const view = document.getElementById('draws-no-more-than-8-rectangles')
      const mountView = drawE.mount
      const evaluated = interpret(options.studentCode, {
        externalFunctions: drawE.availableFunctions,
        state: { elementSerial: 0 },
        language: 'JikiScript',
      })

      const { frames, state } = evaluated
      const actual = state.elementSerial

      const { animations } = drawE
      const animationTimeline = new AnimationTimeline(
        {},
        frames
      ).populateTimeline(animations)

      const expected = 8
      return {
        expectCb: expect(actual).toBeLessThanOrEqual(expected),
        codeRun: '',
        frames,
        view,
        animationTimeline: animationTimeline,
        mountView,
      }
    })
  })
