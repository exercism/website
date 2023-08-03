import { NoFeedbackState } from '.'

export function NoAutomatedFeedbackLHS({
  state,
  initialComponent,
  pendingComponent,
  mentoringRequestFormComponent,
}: {
  state: NoFeedbackState
  initialComponent: JSX.Element
  pendingComponent: JSX.Element
  mentoringRequestFormComponent: JSX.Element
}): JSX.Element {
  switch (state) {
    case 'initial':
      return initialComponent
    case 'pendingMentoringRequest':
      return pendingComponent
    case 'sendingMentoringRequest':
      return mentoringRequestFormComponent
  }
}
