// i18n-key-prefix: chatUsage
// i18n-namespace: components/editor/AssistantChat
import i18n from '@/i18n/i18n'
import type { SignatureData, UsageMeta } from './types'
import type { UsageScope } from './chatApi'

export interface UsageStatus {
  // The binding scope: whichever limit has the fewest messages remaining.
  // Monthly wins ties, mirroring the proxy's own precedence.
  scope: UsageScope
  used: number
  limit: number
  // At or over the binding limit — the composer should be blocked.
  atCap: boolean
  // Within the warning band (>=90% of the binding limit) but not yet at the cap.
  warning: boolean
}

// Show the "getting close" warning once the binding limit is 90% consumed.
const WARNING_THRESHOLD = 0.9

// Pull the four usage fields off a signature event, returning null unless all
// are present.
export function extractUsage(
  signature: SignatureData | null
): UsageMeta | null {
  if (
    !signature ||
    signature.messagesToday == null ||
    signature.messagesThisMonth == null ||
    signature.dailyLimit == null ||
    signature.monthlyLimit == null
  ) {
    return null
  }
  return {
    messagesToday: signature.messagesToday,
    messagesThisMonth: signature.messagesThisMonth,
    dailyLimit: signature.dailyLimit,
    monthlyLimit: signature.monthlyLimit,
  }
}

export function deriveUsageStatus(usage: UsageMeta | null): UsageStatus | null {
  if (!usage) {
    return null
  }

  const dailyRemaining = usage.dailyLimit - usage.messagesToday
  const monthlyRemaining = usage.monthlyLimit - usage.messagesThisMonth

  // Binding scope = fewest messages remaining; monthly wins ties.
  const scope: UsageScope =
    monthlyRemaining <= dailyRemaining ? 'monthly' : 'daily'
  const used =
    scope === 'monthly' ? usage.messagesThisMonth : usage.messagesToday
  const limit = scope === 'monthly' ? usage.monthlyLimit : usage.dailyLimit

  const atCap = used >= limit
  const warning = !atCap && used >= Math.ceil(limit * WARNING_THRESHOLD)

  return { scope, used, limit, atCap, warning }
}

// Copy for the soft "getting close" warning shown under the composer.
export function usageWarningText(status: UsageStatus): string {
  const options = { used: status.used, limit: status.limit }
  if (status.scope === 'monthly') {
    return i18n.t(
      'components/editor/AssistantChat:chatUsage.closeToMonthlyLimit',
      options
    )
  }
  return i18n.t(
    'components/editor/AssistantChat:chatUsage.closeToDailyLimit',
    options
  )
}

// Copy for the terminal "you've hit the cap" notice. Reset times are UTC.
export function usageLimitText(scope: UsageScope, limit: number): string {
  if (scope === 'monthly') {
    return i18n.t(
      'components/editor/AssistantChat:chatUsage.usedAllMonthlyMessages',
      { limit }
    )
  }
  return i18n.t(
    'components/editor/AssistantChat:chatUsage.usedAllDailyMessages',
    { limit }
  )
}
