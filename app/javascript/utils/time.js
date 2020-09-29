import dayjs from 'dayjs'
import RelativeTime from 'dayjs/plugin/relativeTime'
dayjs.extend(RelativeTime)

export function fromNow(dateTime) {
  return dayjs(dateTime).fromNow()
}
