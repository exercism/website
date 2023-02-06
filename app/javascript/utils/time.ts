import dayjs from 'dayjs'
import type { ConfigType } from 'dayjs'
import RelativeTime from 'dayjs/plugin/relativeTime'
import AdvancedFormat from 'dayjs/plugin/advancedFormat'
import pluralize from 'pluralize'
dayjs.extend(RelativeTime)
dayjs.extend(AdvancedFormat)

const SECONDS_PER_MINUTE = 60
const SECONDS_PER_HOUR = SECONDS_PER_MINUTE * 60
const SECONDS_PER_DAY = SECONDS_PER_HOUR * 24
const SECONDS_PER_MONTH = SECONDS_PER_DAY * 31

// The short flag turns "2 days ago" into "2d ago"
export function fromNow(dateTime: ConfigType) {
  return dayjs(dateTime).fromNow()
}

export function shortFromNow(dateTime: ConfigType) {
  const relative = fromNow(dateTime)

  if (relative == 'a few seconds ago' || relative === 'in a few seconds') {
    return 'now'
  }

  const parts = relative.split(' ')
  const inFuture = parts[0] === 'in'
  const time = inFuture ? [parts[1], parts[2]] : [parts[0], parts[1]]
  const val = time[0] == 'a' || time[0] == 'an' ? 1 : time[0]
  let unit

  switch (time[1]) {
    case 'month':
    case 'months':
      unit = 'mo'

      break
    default:
      unit = time[1][0]
  }

  return inFuture ? `in ${val}${unit}` : `${val}${unit} ago`
}

export function timeFormat(dateTime: ConfigType, template: string) {
  return dayjs(dateTime).format(template)
}

export function durationFromSeconds(seconds: number): string {
  const duration = (limit: number, unitDivider: number, unit: string) => {
    if (seconds < limit) {
      const units = Math.floor(seconds / unitDivider)
      return `${units} ${pluralize(unit, units)}`
    }

    return null
  }

  return (duration(SECONDS_PER_MINUTE, 1, 'second') ||
    duration(SECONDS_PER_HOUR, SECONDS_PER_MINUTE, 'minute') ||
    duration(SECONDS_PER_DAY, SECONDS_PER_HOUR, 'hour') ||
    duration(SECONDS_PER_MONTH, SECONDS_PER_DAY, 'day') ||
    duration(Number.MAX_VALUE, SECONDS_PER_MONTH, 'month'))!
}

export function durationTimeElementFromSeconds(seconds: number) {
  const days = Math.floor(seconds / SECONDS_PER_DAY)
  seconds %= SECONDS_PER_DAY

  const hours = Math.floor(seconds / SECONDS_PER_HOUR)
  seconds %= SECONDS_PER_HOUR

  const minutes = Math.floor(seconds / SECONDS_PER_MINUTE)
  seconds %= SECONDS_PER_MINUTE

  return `P ${days}D ${hours}H ${minutes}M ${seconds}S`
}
