import React, { useEffect } from 'react'

type PaginationProps = {
  disabled?: boolean
  current: number
  total: number
  around?: number
  setPage: (page: number) => void
}

export function Pagination({
  disabled = false,
  current = 1,
  total,
  setPage,
  around = 2,
}: PaginationProps): JSX.Element | null {
  if (total <= 1) {
    return null
  }

  useEffect(() => {
    if (current > total) {
      setPage(total)
    } else if (current < 1) {
      setPage(1)
    }
  }, [total, current, setPage])

  if (current < 1 || current > total) {
    return null
  }

  current = Number(current)
  around = Number(around)
  total = Number(total)

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
    <div className="c-pagination">
      <div className="--pagination-lhs">
        <button
          onClick={() => {
            setPage(1)
          }}
          disabled={disabled || current == 1}
          aria-label="Go to first page"
        >
          First
        </button>
        <button
          onClick={() => {
            setPage(current - 1)
          }}
          disabled={disabled || current == 1}
          aria-label="Go to previous page"
        >
          Previous
        </button>
      </div>
      <div className="--pagination-pages">
        {current - around > 1 ? (
          <>
            <button
              key={1}
              onClick={() => {
                setPage(1)
              }}
              aria-label={'Go to page 1'}
            >
              1
            </button>
          </>
        ) : null}
        {current - around > 2 ? (
          <div className="--pagination-more">…</div>
        ) : null}

        {range.map((page) => {
          return (
            <button
              key={page}
              onClick={() => {
                setPage(page)
              }}
              disabled={disabled || page === current}
              aria-label={`Go to page ${page}`}
              aria-current={page === current ? 'page' : undefined}
              className={page === current ? 'current' : undefined}
            >
              {page}
            </button>
          )
        })}

        {total - current > around + 1 ? (
          <div className="--pagination-more">…</div>
        ) : null}

        {total - current > around ? (
          <>
            <button
              key={total}
              onClick={() => {
                setPage(total)
              }}
              aria-label={`Go to page ${total}`}
            >
              {total}
            </button>
          </>
        ) : null}
      </div>
      <div className="--pagination-rhs">
        <button
          onClick={() => {
            setPage(current + 1)
          }}
          disabled={disabled || current == total}
          aria-label="Go to next page"
        >
          Next
        </button>
        <button
          onClick={() => {
            setPage(total)
          }}
          disabled={disabled || current == total}
          aria-label="Go to last page"
        >
          Last
        </button>
      </div>
    </div>
  )
}
