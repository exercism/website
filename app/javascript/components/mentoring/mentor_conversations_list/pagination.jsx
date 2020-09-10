import React from 'react'

export function Pagination({ current, total, setPage, around = 3 }) {
  const range = new Range(
    Math.max(current - around, 1),
    Math.min(current + around, total)
  )

  function Range(start, end) {
    return Array(end - start + 1)
      .fill()
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
        aria-current={current === 1 ? 'page' : null}
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
            aria-current={page === current ? 'page' : null}
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
        aria-current={current === total ? 'page' : null}
      >
        Last
      </button>
    </div>
  )
}
