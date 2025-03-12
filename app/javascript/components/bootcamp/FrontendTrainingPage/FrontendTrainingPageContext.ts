import { createContext } from 'react'

type FrontendTrainingPageContextType = {
  actualIFrameRef: React.RefObject<HTMLIFrameElement>
  expectedIFrameRef: React.RefObject<HTMLIFrameElement>
  expectedReferenceIFrameRef: React.RefObject<HTMLIFrameElement>
}

export const FrontendTrainingPageContext =
  createContext<FrontendTrainingPageContextType | null>(null)
