# Stripe

This document explains how stripe works in this app.

## JS Integration

We use Stripe's Elements and React JS libraries.
The relevant components live in `app/javascript/components/stripe`.

The entry point is `Form.tsx`.
This renders a form with options for one-off or monthly donations and various price points.
This in turn renders `StripeForm.tsx`, which is where all the Stripe magic itself lives.
You'll notice between these two is an Elements element.
This is an async element that pairs with `loadStripe()` to get things going.
It's also worth being aware that you can only have one `CardElement` in your app, and it has to live in a nested component below the `<Elements>`, which is why this is encapsulated this way.

The basic flow is as follows:

- Someone clicks buttons to tell us the transaction type (one off or subscription) and the amount. These are saved as state.
- Someone fills out the CardElement (this is an iframe hosted by Stripe), and then clicks Donate.
- This does a few things:
  - Ping the server to setup a "Payment Intent".
    Payment Intents are Stripe's encapsulation of the payment process.
    Depending on the type of the transaction, this will either create a `Stripe::PaymentIntent` for a one-off payment, or create a `Stripe::Subscription` and retrieve the `Stripe::PaymentIntent` from it.
    We then return the id and a secret back to the client.
  - Ping Stripe with the PaymentIntent's secret to try and complete the transaction.
  - If it succeeds, we notify the server that a new payment or subscription has been made.
  - If it fails, we notify the server that the `PaymentIntent` (and the subscription/invoice) should all be voided.
    There is currently no way to update a PaymentIntent, so we have to void everything each time things fail.
  - We then bubble up an `handleSuccess` event which can be handled in whatever way is appropriate to the context of the form.

In the database we store:

- Each user's subscriptions (and their activeness)
- Any payments a user makes.

These allow us to pivot on things like whether a user is an active subscriber, and tell user's their total donation amount to date.
We also cache these values on the user model to avoid lots of db lookups.

### Webhooks

You test webhooks locally you can run:

```
stripe listen --forward-to local.exercism.io:3020/webhooks/stripe
```

Then trigger events with:

```
stripe trigger payment_intent.succeeded
```

## Setting things up

### Login

Install the stripe CLI then login with the following command:

```
stripe login
```

## Create product(s)

Now we need to create a product for recurring payments.

```
stripe products create \
  --name="Recurring Exercism Donation" \
  --description="A recurring donation to Exercism"
```

Store the id in `config/initializers/stripe.rb`

Note: Most tutorials will also expect you to create "prices" but we don't bother with that as users can choose their own price.
