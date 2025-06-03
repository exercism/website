export function formatDuration(duration: number): string {
  const minutes: number = Math.floor(duration / 60)
  const seconds: number = duration % 60

  const paddedMinutes: string = minutes.toString().padStart(2, '0')
  const paddedSeconds: string = seconds.toString().padStart(2, '0')

  return `${paddedMinutes}:${paddedSeconds}`
}
