module BotPortal::actions {
    use aptos_framework::account::{Self, SignerCapability};
    use aptos_framework::resource_account;
    use aptos_framework::aptos_coin;
    use aptos_framework::event;
    use aptos_framework::coin;

    use std::signer;
    use std::string::{String, utf8};

    #[event]
    struct TweetReplyEvent has drop, store {
        user: address,
        tweet_link: String,
        status: String,
        amount_paid: u64
    }

    #[resource_group_member(group = aptos_framework::object::ObjectGroup)]
    struct Admin has key {
        signer_cap: SignerCapability,
        admin_addr: address
    }

    #[resource_group_member(group = aptos_framework::object::ObjectGroup)]
    struct TweetReplyCost has key {
        reply_cost_in_apt: u64
    }

    const TWEET_REPLY_COST: u64 = 200000000;

    const STATUS_PENDING: vector<u8> = b"PENDING";

    fun init_module(admin: &signer) {
        create_resource_signer(admin, @publisher);
        move_to(admin, TweetReplyCost{
            reply_cost_in_apt: TWEET_REPLY_COST,
        });
    }

    fun create_resource_signer(
        resource_account: &signer, admin_addr: address
    ) {
        if (exists<Admin>(signer::address_of(resource_account))) {
            return ()
        };

        let resource_signer_cap =
            resource_account::retrieve_resource_account_cap(resource_account, admin_addr);
        move_to(
            resource_account,
            Admin { signer_cap: resource_signer_cap, admin_addr: admin_addr }
        );
    }

    inline fun get_admin_resource(): &mut Admin acquires Admin {
        borrow_global_mut<Admin>(@BotPortal)
    }

    inline fun get_tweet_reply_cost(): &mut TweetReplyCost acquires TweetReplyCost {
        borrow_global_mut<TweetReplyCost>(@BotPortal)
    }

    fun create_event(sender: &signer, tweet_link: String, status: String, amount_paid: u64): TweetReplyEvent {
        TweetReplyEvent{
            user: signer::address_of(sender),
            tweet_link,
            status,
            amount_paid
        }
    }

    #[test_only]
    public fun setup_for_test(resource_account: &signer) {
        init_module(resource_account);
    }

    #[test_only]
    public fun check_tweet_reply_event_emitted(
        sender: &signer,
        tweet_link: String,
        amount_paid: u64,
        status: String
    ): bool {
        let event = &TweetReplyEvent {
            user: signer::address_of(sender),
            tweet_link,
            amount_paid,
            status
        };
        event::was_event_emitted(event)
    }

    public(friend) fun get_signer_internal(): signer acquires Admin {
        let admin_object = get_admin_resource();
        account::create_signer_with_capability(&admin_object.signer_cap)
    }

    public fun reply_to_tweet(sender: &signer, tweet_link: String) acquires TweetReplyCost, Admin {
        let resource_account = &get_signer_internal();
        let resource_account_address = signer::address_of(resource_account);
        let amount = get_tweet_reply_cost().reply_cost_in_apt;

        coin::transfer<aptos_coin::AptosCoin>(sender, resource_account_address, amount);

        let tweet_reply_event = create_event(sender, tweet_link, utf8(STATUS_PENDING), amount);

        event::emit(tweet_reply_event);
    }

}
