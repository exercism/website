import dayjs from 'dayjs'
import type { ConfigType } from 'dayjs'
import RelativeTime from 'dayjs/plugin/relativeTime'
import pluralize from 'pluralize'
dayjs.extend(RelativeTime)

export function fromNow(date: ConfigType, titleize = false): string {
  const now = dayjs()
  const from = dayjs(date)

  const days = now.diff(from, 'day')
  const weeks = now.diff(from, 'week')
  const months = now.diff(from, 'month')
  const years = now.diff(from, 'year')

  if (years >= 1) {
    return `${years} ${pluralize('year', years)} ago`
  } else if (months >= 1) {
    return `${months} ${pluralize('month', months)} ago`
  } else if (weeks >= 1) {
    return `${weeks} ${pluralize('weeks', weeks)} ago`
  } else if (days > 1) {
    return `${days} ${pluralize('days', weeks)} ago`
  } else if (days === 1) {
    return titleize ? 'Yesterday' : 'yesterday'
  } else {
    return titleize ? 'Today' : 'today'
  }
}
