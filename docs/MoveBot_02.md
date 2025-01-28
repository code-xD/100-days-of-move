# 🤖 Move Bot Day 06: Setting up Bot Portal

Till now, we discussed the architecture of Move Bot and how it will interact with Eliza and Movement Blockchain. Today we will talk about setting up the `BotPortal` package which will act as an entry point for users to pay the bot to reply to user's tweets.

## Setting Up

In order to deploy our code, the following are the steps.

1. Go to [BotPortal](../demos/movement-mania/BotPortal).
2. Run all the setup commands required just before deployement.
3. For deployment run the following command.

```bash
movement move create-resource-account-and-publish-package \
--seed <seed_phrase> \
--named-addresses publisher=default \
--address-name BotPortal
```

This command will yield the following output. For more details refer the [README](../demos/movement-mania/BotPortal/README.md)

```bash
Compiling, may take a little while to download git dependencies...
UPDATING GIT DEPENDENCY https://github.com/movementlabsxyz/aptos-core.git
INCLUDING DEPENDENCY AptosFramework
INCLUDING DEPENDENCY AptosStdlib
INCLUDING DEPENDENCY MoveStdlib
BUILDING BotPortal
Do you want to publish this package under the resource account's address 0xaa3aca2ff971ab329b2857a06dc1d28650ef0af6da872ee8b7cb64198568d5a3? [yes/no] >
yes
package size 2717 bytes
Do you want to submit a transaction for a range of [349400 - 524100] Octas at a gas unit price of 100 Octas? [yes/no] >
yes
Transaction submitted: https://explorer.movementlabs.xyz/txn/0x8d9b626cf15233f3440b640b2d4b361ecd75b6f8529224696702ef9f37b067ec?network=custom
{
  "Result": "Success"
}
```

Post deployment user can go to the explorer and enter the details to interact with the Package.

## Background

### Resource Account

In the package we would have seen that we are using the `resource_account` module. So what are Resource Accounts? As we had discussed in the [Object Basics](ObjectBasics.md) resource accounts are accounts with signer capability which are created linked to the user account.

Most of the resource creation operations on Movement requires a signer. However, using a user's signer is not a scalable approach. There could be access control related operations where certain resource needs to be created by the package itself.

Movement calls `init_module` to create resources at the time of deployment however, in Object deployment that signer is lost can't be found again. This is useful in case of non-custodial packages i.e. each user perform actions in their own silos.

However, in packages where we want to strictly define roles to various addresses, Resource Account based deployment comes in clutch. When the deployment of package happens, the `init_module` function has the signer of the Resource Account. Using the module `resource_account` user can extract the `SignerCap` and store it immutably. This `SignerCap` can then be used to generate the signer again.

Refer to `create_resource_signer` function for `SignerCap` retrieval.

```Move
fun create_resource_signer(
    resource_account: &signer, admin_addr: address
) {
    if (exists<Admin>(signer::address_of(resource_account))) {
        return ()
    };

    let resource_signer_cap = 
        resource_account::retrieve_resource_account_cap(resource_account, admin_addr);
    coin::register<aptos_coin::AptosCoin>(resource_account);

    move_to(
        resource_account,
        Admin { signer_cap: resource_signer_cap, admin_addr: admin_addr }
    );
}
```

And one can refer `get_signer_interval` to see the `signer` creation from `SignerCap` workflow.

```Move
public(friend) fun get_signer_internal(): signer acquires Admin {
    let admin_object = get_admin_resource();
    account::create_signer_with_capability(&admin_object.signer_cap)
}
```

### Coin Standard (Move Token)

We talked about [Fungible Assets](FungibleAssetsBasicsI.md) in much greater depth, it's important to note that Fungible Asset is a very new standard. The native gas token of Movement `MOVE` token is based on **Coin** standard. In the Coin standard each account holding the coin has a `CoinStore<CoinType>` which stores the account balance for that coin. One can refer to `aptos_coin.move` code to see how the Move is to be used.

User's can call `coin::transfer` function to transfer the coin.

```Move
coin::transfer<aptos_coin::AptosCoin>(sender, resource_account_address, amount);
```

And similarly user's can call `coin::register` to register a CoinStore in an account.

```Move
coin::register<aptos_coin::AptosCoin>(resource_account);
```

### Events

The final piece of the puzzle is events. In any blockchain events play a crucial role. Any off-chain activity can be linked to any on-chain transaction with the help of events.

Event's can be considered as a stamp in blockchain which oracles and bots can listen to trigger any off-chain activity. In `MoveBot` whenever `BotPortal`emits`TweetReplyEvent` the event streamer can listen to this event to trigger the sentiment based reply workflow.

Receiving the `TweetReplyEvent` means that a given successfully user has paid the `BotPortal` to trigger a reply to a tweet.

In order to trigger an Event user can call `event::emit`.

```Move
fun create_event(sender: &signer, tweet_link: String, status: String, amount_paid: u64): TweetReplyEvent {
    TweetReplyEvent{
        user: signer::address_of(sender),
        tweet_link,
        status,
        amount_paid
    }
}
```

And in unit tests user's can call `event::was_event_emitted` to check if event was emitted.

```Move
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
```

## Resources

- [Resource Accounts](https://aptos.dev/en/build/smart-contracts/resource-accounts)
- [Coin Standard](https://aptos.dev/en/build/smart-contracts/aptos-coin#creators)
- [aptos_coin.move](https://github.com/movementlabsxyz/aptos-core/blob/movement/aptos-move/framework/aptos-framework/sources/aptos_coin.move)
- [Events](https://github.com/movementlabsxyz/aptos-core/blob/movement/aptos-move/framework/aptos-framework/sources/event.move)
