import { getDiffOfExpectedAndActual } from '../../../../app/javascript/components/bootcamp/SolveExercisePage/TestResultsView/useInspectedTestResultView'

test('renders Easy when difficulty is easy', async () => {
  const right = 'One for me, one for you!'
  const wrong = 'One for me ,one for you!'

  const diff = getDiffOfExpectedAndActual(right, wrong)
  const expected = [
    { count: 11, added: false, removed: false, value: '"One for me' },
    { count: 1, added: false, removed: true, value: ',' },
    { count: 1, added: false, removed: false, value: ' ' },
    { count: 1, added: true, removed: false, value: ',' },
    { count: 13, added: false, removed: false, value: 'one for you!"' },
  ]
  expect(diff).toEqual(expected)
})
