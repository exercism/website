import { useMemo, useEffect, useCallback } from 'react'

type UsePaginationArgs = {
  disabled?: boolean
  current: number
  total: number
  around: number
  setPage: (page: number) => void
}

type UsePaginationReturn = {
  valid: boolean
  cur: number
  tot: number
  ar: number
  rangeStart: number
  rangeEnd: number
  range: number[]
  showLeftEllipsis: boolean
  showRightEllipsis: boolean
  canPrev: boolean
  canNext: boolean
  goFirst: () => void
  goPrev: () => void
  goNext: () => void
  goLast: () => void
  goPage: (n: number) => void
}

export function usePagination({
  disabled = false,
  current,
  total,
  around,
  setPage,
}: UsePaginationArgs): UsePaginationReturn {
  const cur = useMemo(() => Number(current), [current])
  const tot = useMemo(() => Number(total), [total])
  const ar = useMemo(() => Number(around), [around])

  const numbersOK = !Number.isNaN(cur) && !Number.isNaN(tot)
  const hasPages = numbersOK && tot > 1

  useEffect(() => {
    if (!hasPages) return
    if (cur < 1) setPage(1)
    else if (cur > tot) setPage(tot)
  }, [cur, tot, hasPages, setPage])

  const rangeStart = useMemo(
    () => (hasPages ? Math.max(cur - ar, 1) : 1),
    [cur, ar, hasPages]
  )
  const rangeEnd = useMemo(
    () => (hasPages ? Math.min(cur + ar, tot) : 1),
    [cur, ar, tot, hasPages]
  )

  const range = useMemo(() => {
    if (!hasPages) return []
    return Array.from(
      { length: rangeEnd - rangeStart + 1 },
      (_, i) => rangeStart + i
    )
  }, [rangeStart, rangeEnd, hasPages])

  const showLeftEllipsis = hasPages && rangeStart > 1
  const showRightEllipsis = hasPages && rangeEnd < tot - 2

  const canPrev = hasPages && cur > 1 && !disabled
  const canNext = hasPages && cur < tot && !disabled

  const goFirst = useCallback(() => setPage(1), [setPage])
  const goPrev = useCallback(
    () => setPage(Math.max(cur - 1, 1)),
    [cur, setPage]
  )
  const goNext = useCallback(
    () => setPage(Math.min(cur + 1, tot)),
    [cur, tot, setPage]
  )
  const goLast = useCallback(() => setPage(tot), [tot, setPage])
  const goPage = useCallback((n: number) => setPage(n), [setPage])

  const valid = Boolean(hasPages && cur >= 1 && cur <= tot)

  return {
    valid,
    cur,
    tot,
    ar,
    rangeStart,
    rangeEnd,
    range,
    showLeftEllipsis,
    showRightEllipsis,
    canPrev,
    canNext,
    goFirst,
    goPrev,
    goNext,
    goLast,
    goPage,
  }
}
