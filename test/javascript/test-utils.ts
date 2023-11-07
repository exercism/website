import { render as rtlRender, RenderOptions } from '@testing-library/react'
import { TestQueryCache } from './support/TestQueryCache'

export const render = (
  ui: React.ReactElement,
  options: Omit<RenderOptions, 'wrapper'> = {}
): ReturnType<typeof rtlRender> => {
  return rtlRender(ui, { wrapper: TestQueryCache, ...options })
}
