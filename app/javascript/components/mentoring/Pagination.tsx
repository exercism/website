import React from 'react'

type PaginationProps = {
  current: number
  total: number
  around: number
  setPage: (page: number) => void
}

export function Pagination({
  current = 1,
  total,
  setPage,
  around = 3,
}: PaginationProps) {
  const range = createRange(
    Math.max(current - around, 1),
    Math.min(current + around, total)
  )

  function createRange(start: number, end: number) {
    return Array(end - start + 1)
      .fill(0)
      .map((_, i) => start + i)
  }

  return (
    <div>
      <button
        onClick={() => {
          setPage(1)
        }}
        disabled={current === 1}
        aria-label="Go to first page"
        aria-current={current === 1 ? 'page' : undefined}
      >
        First
      </button>
      {range.map((page) => {
        return (
          <button
            key={page}
            onClick={() => {
              setPage(page)
            }}
            disabled={page === current}
            aria-label={`Go to page ${page}`}
            aria-current={page === current ? 'page' : undefined}
          >
            {page}
          </button>
        )
      })}
      <button
        onClick={() => {
          setPage(total)
        }}
        disabled={current === total}
        aria-label="Go to last page"
        aria-current={current === total ? 'page' : undefined}
      >
        Last
      </button>
    </div>
  )
}
