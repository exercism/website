import { render, screen, waitFor, act } from '@testing-library/react'
import { awaitPopper } from './await-popper'
import flushPromises from 'flush-promises'

// TODO: Replace this with expectConsoleError everywhere
export function silenceConsole(): void {
  jest.spyOn(console, 'error').mockImplementation(() => {})
}

export async function expectConsoleError(func) {
  let spy = {}
  spy.console = jest.spyOn(console, 'error').mockImplementation((e) => {})

  try {
    await func()
    await flushPromises()
    await awaitPopper()
  } finally {
    spy.console.mockRestore()
  }
}
