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
      >
        Last
      </button>
    </div>
  )
}
