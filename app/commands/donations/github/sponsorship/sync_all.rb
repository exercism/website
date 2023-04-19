# Ensure that our local payments and subscriptions match the Github sponsorships
class Donations::Github::Sponsorship::SyncAll
  include Mandate

  def call
    # create_subscriptions!
    # update_subscriptions!
    # deactivate_subscriptions!
  end

  private
  def create_subscriptions!
    missing_subscription_ids = github_subscription_sponsorships - local_subscription_ids
    missing_subscription_ids.each do |subscription_id|
      github_subscription = active_stripe_subscriptions[subscription_id]
      next unless github_subscription.sponsor

      Donations::Github::Subscription::Create.(
        github_subscription.sponsor, github_subscription[:id], github_subscription[:monthly_price_in_cents]
      )
    end
  end

  memoize
  def github_subscription_sponsorships
    github_sponsorships.select { |_, sponsorship| sponsorship[:is_one_time_payment] }
  end

  memoize
  def github_subscription_sponsorship_ids = github_subscription_sponsorships.keys

  memoize
  def github_sponsorships
    Github::Graphql::ExecuteQuery.(QUERY, %i[organization sponsorshipsAsMaintainer]).flat_map do |data|
      data[:nodes].map do |node|
        {
          id: node[:id],
          sponsor: User.find_by(github_username: node[:sponsorEntity][:login]),
          privacy_level: node[:privacyLevel].downcase,
          is_one_time_payment: node[:isOneTimePayment],
          monthly_price_in_cents: node[:tier][:monthlyPriceInCents]
        }
      end
    end.index_by(&:id)
  end

  memoize
  def github_sponsorship_ids = github_sponsorships.keys

  memoize
  def local_payments = Donations::Payment.github.find_each.index_by(&:external_id)

  memoize
  def local_payment_ids = local_subscriptions.keys

  memoize
  def local_subscriptions = Donations::Subscription.github.find_each.index_by(&:external_id)

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
            privacyLevel
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

  # def update_subscriptions!
  #   subscription_ids = local_subscription_ids & active_stripe_subscription_ids
  #   subscription_ids.each do |subscription_id|
  #     subscription = local_subscriptions[subscription_id]
  #     stripe_subscription = active_stripe_subscriptions[subscription_id]

  #     update_subscription_status(subscription, stripe_subscription)
  #   end
  # end

  # def deactivate_subscriptions!
  #   inactive_subscription_ids = local_subscription_ids - active_stripe_subscription_ids
  #   inactive_subscription_ids.each do |subscription_id|
  #     subscription = local_subscriptions[subscription_id]
  #     stripe_subscription = Stripe::Subscription.retrieve(subscription_id)

  #     update_subscription_status(subscription, stripe_subscription)
  #   end
  # end

  # memoize
  # def active_stripe_subscriptions
  #   subscriptions = Stripe::Subscription.search({
  #     query: "status:'active'",
  #     limit: 100,
  #     expand: ["data.customer"]
  #   })

  #   subscriptions.auto_paging_each.index_by(&:id)
  # end

  # memoize
  # def active_stripe_subscription_ids = active_stripe_subscriptions.keys

  # memoize
  # def local_subscriptions = Donations::Subscription.stripe.find_each.index_by(&:external_id)

  # memoize
  # def local_subscription_ids = local_subscriptions.keys

  # def update_subscription_status(subscription, stripe_subscription)
  #   status = SUBSCRIPTION_STATUSES.fetch(stripe_subscription&.status, :canceled)

  #   subscription.update(status:)

  #   Donations::Subscription::Deactivate.(subscription) if subscription.canceled?
  # end

  # def subscription_user(subscription)
  #   stripe_user = User.find_by(stripe_customer_id: subscription.customer.id)
  #   return stripe_user if stripe_user

  #   User.find_by(email: subscription.customer.email)&.tap do |user|
  #     user.update(stripe_customer_id: subscription.customer.id)
  #   end
  # end
end
