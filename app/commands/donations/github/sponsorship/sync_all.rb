# Ensure that our local payments and subscriptions match the Github sponsorships
class Donations::Github::Sponsorship::SyncAll
  include Mandate

  def call
    create_subscriptions_and_payments!
    # update_subscriptions_and_payments!
    deactivate_subscriptions!
  end

  private
  def create_subscriptions_and_payments!
    missing_or_incomplete_sponsorship_ids = github_sponsorship_ids - (local_subscription_ids & local_payment_ids)
    missing_or_incomplete_sponsorship_ids.each do |sponsorship_id|
      github_sponsorship = github_sponsorships[sponsorship_id]

      Donations::Github::Sponsorship::HandleCreated.defer(
        github_sponsorship[:sponsor],
        github_sponsorship[:id],
        github_sponsorship[:privacy_level],
        github_sponsorship[:is_one_time_payment],
        github_sponsorship[:monthly_price_in_cents]
      )
    end
  end

  def deactivate_subscriptions!
    cancelled_sponsorship_ids = local_subscription_ids - github_sponsorship_ids
    cancelled_sponsorship_ids.each do |sponsorship_id|
      subscription = local_subscriptions[sponsorship_id]

      Donations::Github::Sponsorship::HandleCancelled.defer(
        subscription.user,
        subscription.external_id,
        subscription.user.show_on_supporters_page ? 'public' : 'private',
        false,
        subscription.amount_in_cents
      )
    end
  end

  memoize
  def github_sponsorships
    sponsorships = Github::Graphql::ExecuteQuery.(QUERY, %i[organization sponsorshipsAsMaintainer]).flat_map do |data|
      data[:nodes].filter_map do |node|
        sponsor = User.find_by(github_username: node[:sponsorEntity][:login])
        next unless sponsor

        {
          id: node[:id],
          privacy_level: node[:privacyLevel].downcase,
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
  def local_payments = Donations::Payment.github.find_each.index_by(&:external_id)

  memoize
  def local_payment_ids = local_payments.keys

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

  # def update_subscriptions_and_payments!
  #   subscription_ids = local_subscription_ids & active_stripe_subscription_ids
  #   subscription_ids.each do |subscription_id|
  #     subscription = local_subscriptions[subscription_id]
  #     stripe_subscription = active_stripe_subscriptions[subscription_id]

  #     update_subscription_status(subscription, stripe_subscription)
  #   end
  # end

  # def deactivate_subscriptions_and_payments!
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
