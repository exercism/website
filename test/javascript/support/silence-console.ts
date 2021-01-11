export function silenceConsole(): void {
  jest.spyOn(console, 'error').mockImplementation(() => {})
}
