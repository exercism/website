import { render, screen, waitFor, act } from '@testing-library/react'
import { awaitPopper } from './await-popper'

// TODO: Replace this with expectConsoleError everywhere
export function silenceConsole(): void {
  jest.spyOn(console, 'error').mockImplementation(() => {})
}

export async function expectConsoleError(func) {
  let spy = {}
  spy.console = jest.spyOn(console, 'error').mockImplementation((e) => {})

  try {
    await func()
    await awaitPopper()
  } finally {
    spy.console.mockRestore()
  }
}
