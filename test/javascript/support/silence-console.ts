import { render, screen, waitFor, act } from '@testing-library/react'

export function silenceConsole(): void {
  // jest.spyOn(console, 'error').mockImplementation(() => {})
}

export async function expectConsoleError(func) {
  let spy = {}
  spy.console = jest.spyOn(console, 'error').mockImplementation((e) => {})

  try {
    await func()
  } finally {
    spy.console.mockRestore()
  }
}
