export function deferred() {
  let resolve: () => void

  const promise = new Promise<void>((res) => {
    resolve = res
  })

  return { promise }
}
