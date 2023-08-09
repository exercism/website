import { NoFeedbackState } from '.'

export function NoAutomatedFeedbackLHS({
  state,
  initialComponent,
  pendingComponent,
  inProgressComponent,
  mentoringRequestFormComponent,
}: {
  state: NoFeedbackState
  initialComponent: JSX.Element
  pendingComponent: JSX.Element
  inProgressComponent: JSX.Element
  mentoringRequestFormComponent: JSX.Element
}): JSX.Element {
  switch (state) {
    case 'requested':
      return pendingComponent
    case 'in_progress':
      return inProgressComponent
    case 'sendingMentoringRequest':
      return mentoringRequestFormComponent
    default:
      return initialComponent
  }
}
