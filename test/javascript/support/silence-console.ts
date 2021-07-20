import { render, screen, waitFor, act } from '@testing-library/react'
import { awaitPopper } from './await-popper'

jest.mock

// TODO: Replace this with expectConsoleError everywhere
export function silenceConsole(): void {
  jest.spyOn(console, 'error').mockImplementation(() => {})
}

export async function expectConsoleError(func) {
  const spy = jest.spyOn(console, 'error').mockImplementation(() => null)

  try {
    await func()
  } finally {
    spy.mockRestore()
  }
}
