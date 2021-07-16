## Login

```
stripe login
```

## Create product(s)

```
stripe products create \
  --name="Exercism Donation" \
  --description="A donation to Exercism"

stripe products create \
  --name="Recurring Exercism Donation" \
  --description="A recurring donation to Exercism"
```

**Save the product IDs in config/initializers/stripe.rb**

Note: We don't create prices as those are ad-hoc.

## TODO:

- [ ] Replace the `pk` key in app/javascript/components/stripe/SubscriptionForm.tsx
