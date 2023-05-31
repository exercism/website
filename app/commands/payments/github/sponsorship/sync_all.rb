# Ensure that our local payments and subscriptions match the Github sponsorships
class Payments::Github::Sponsorship::SyncAll
  include Mandate

  def call
    create_subscriptions_and_payments!
    update_subscriptions!
    deactivate_subscriptions!
  end

  private
  def create_subscriptions_and_payments!
    missing_or_incomplete_sponsorship_ids = github_sponsorship_ids - (local_subscription_ids & local_payment_ids)
    missing_or_incomplete_sponsorship_ids.each do |sponsorship_id|
      github_sponsorship = github_sponsorships[sponsorship_id]

      Payments::Github::Sponsorship::HandleCreated.defer(
        github_sponsorship[:sponsor],
        github_sponsorship[:id],
        github_sponsorship[:is_one_time_payment],
        github_sponsorship[:monthly_price_in_cents]
      )
    end
  end

  def update_subscriptions!
    existing_sponsorship_ids = local_subscription_ids & github_sponsorship_ids
    existing_sponsorship_ids.each do |sponsorship_id|
      subscription = local_subscriptions[sponsorship_id]
      github_sponsorship = github_sponsorships[sponsorship_id]

      Payments::Github::Sponsorship::HandleTierChanged.defer(
        subscription.user,
        subscription.external_id,
        github_sponsorship[:is_one_time_payment],
        github_sponsorship[:monthly_price_in_cents]
      )
    end
  end

  def deactivate_subscriptions!
    cancelled_sponsorship_ids = local_subscription_ids - github_sponsorship_ids
    cancelled_sponsorship_ids.each do |sponsorship_id|
      subscription = local_subscriptions[sponsorship_id]

      Payments::Github::Sponsorship::HandleCancelled.defer(
        subscription.user,
        subscription.external_id,
        false
      )
    end
  end

  memoize
  def github_sponsorships
    sponsorships = Github::Graphql::ExecuteQuery.(QUERY, %i[organization sponsorshipsAsMaintainer]).flat_map do |data|
      data[:nodes].filter_map do |node|
        sponsor = User.with_data.find_by(data: { github_username: node[:sponsorEntity][:login] })
        next unless sponsor

        {
          id: node[:id],
          is_one_time_payment: node[:isOneTimePayment],
          monthly_price_in_cents: node[:tier][:monthlyPriceInCents],
          sponsor:
        }
      end
    end

    sponsorships.index_by { |sponsorship| sponsorship[:id] }
  end

  memoize
  def github_sponsorship_ids = github_sponsorships.keys

  memoize
  def local_payments = Payments::Payment.github.find_each.index_by(&:external_id)

  memoize
  def local_payment_ids = local_payments.keys

  memoize
  def local_subscriptions = Payments::Subscription.github.find_each.index_by(&:external_id)

  memoize
  def local_subscription_ids = local_subscriptions.keys

  QUERY = <<~QUERY.strip
    query ($endCursor: String) {
      organization(login: "exercism") {
        sponsorshipsAsMaintainer(
          first: 100
          activeOnly: true
          includePrivate: true
          after: $endCursor
        ) {
          nodes {
            sponsorEntity {
              ... on User {
                login
              }
            }
            id
            isOneTimePayment
            tier {
              monthlyPriceInCents
            }
          }
          pageInfo {
            hasNextPage
            endCursor
          }
        }
      }
    }
  QUERY
  private_constant :QUERY
end
