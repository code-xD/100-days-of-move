#[test_only]
module BotPortal::actions_test {
    use aptos_framework::resource_account;
    use aptos_framework::aptos_account;
    use aptos_framework::aptos_coin;
    use aptos_framework::coin;

    use std::vector;
    use std::signer;
    use std::string::{utf8};

    use BotPortal::actions;

    // creates resource account from a given user account for testing.
    public fun setup_for_test(source: &signer, aaron: &signer, resource_account: &signer) {
        aptos_coin::ensure_initialized_with_apt_fa_metadata_for_test();
        aptos_account::create_account(signer::address_of(source));
        aptos_account::create_account(signer::address_of(aaron));

        resource_account::create_resource_account(
            source, vector::empty(), vector::empty()
        );

        coin::register<aptos_coin::AptosCoin>(source);
        coin::register<aptos_coin::AptosCoin>(aaron);
        coin::register<aptos_coin::AptosCoin>(resource_account);
    }

    #[test(resource_account = @BotPortal, admin = @publisher, aaron = @0xCAFE, framework = @aptos_framework)]
    fun test_basic_flow(resource_account: &signer, admin: &signer, aaron: &signer, framework: &signer) {
        setup_for_test(admin, aaron, resource_account);
        actions::setup_for_test(resource_account);

        let aaron_address = signer::address_of(aaron);
        aptos_coin::mint(framework, aaron_address, 200000000);

        actions::reply_to_tweet(aaron, utf8(b"Test"));

        assert!(
            actions::check_tweet_reply_event_emitted(aaron, utf8(b"Test"), 200000000, utf8(b"PENDING")),
            1
        );

        assert!(coin::balance<aptos_coin::AptosCoin>(aaron_address) == 0, 2);
        assert!(coin::balance<aptos_coin::AptosCoin>(signer::address_of(resource_account)) == 200000000, 3);
    }

}
