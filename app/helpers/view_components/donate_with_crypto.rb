module ViewComponents
  class DonateWithCrypto < ViewComponent
    extend Mandate::Memoize

    def to_s
      tag.div do
        button + js
      end
    end

    def button
      custom_data = current_user ? "user-#{current_user.id}" : nil
      url = "https://commerce.coinbase.com/checkout/ceb7bf37-2622-4615-a1db-69de8adfe648"
      link_to url, data: { custom: custom_data, styled: false }, class: "donate-with-crypto btn-m !flex !py-8 !px-16" do
        graphical_icon("coinbase", category: :graphics, css_class: "!filter-none") +
          tag.span("Donate with Crypto", class: "!text-[16px] !font-body")
      end
    end

    def js
      javascript_include_tag "https://commerce.coinbase.com/v1/checkout.js?version=201807"
    end
  end
end
