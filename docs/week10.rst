Week 10 - Uniswap
=================

.. note::
      These is a written version of `Lecture
      #10 <https://youtu.be/Dg36h9YPMz4>`__.

      In this lecture we look at an implementation of Uniswap in Plutus.

      This is the last lecture in the Plutus Pioneer Program. However, there will be a special lecture once it is possible to deploy contracts to the testnet.

In this lecture we won't be introducing any new topics or concepts. Instead we will do an end-to-end walk through of a demo that Lars wrote some months ago that 
clones the very popular Uniswap contract from Ethereum.

The one new thing we will look at following several requests is how you can query the endpoints created by the PAB with Curl commands just from the console.

What is Uniswap
---------------

So for those of you who haven't heard of Uniswap, what is Uniswap?

Uniswap is a so-called DeFi, or decentralized finance application, that allows swapping of tokens without any central authority. In 
the case of Ethereum it's ERC20 tokens.

So you don't need a centralized exchange, the traditional way to exchange tokens or other crypto assets. Instead everything is governed by 
smart contracts and works fully automatically on the blockchain.

Another interesting feature of Uniswap is that it doesn't discover prices the usual way with the so-called order book, but uses a different
automatic price discovery system. The idea is that people can create so-called liquidity pools. 

If they want other users to be able to swap two different tokens, then somebody can create a liquidity pool and put a certain amount of those two tokens 
in this liquidity pool, and in return the creator of the pool will receive so-called liquidity tokens that are specific to this one pool. 

Other users can use that pool to swap. They take some amount of one of the tokens out in exchange for putting an amount of the other token back in.

Additionally, people can also add liquidity to the pool and receive liquidity tokens, or they can also burn liquidity tokens in exchange for tokens from the pool.

And all these features are also implemented in the version of Uniswap that works on Cardano that we're going to look at now.

.. figure:: img/pic__00149.png

So let's look at the various operations that are available in turn.

It all starts by somebody setting up the whole system. So some organization or entity that wants to offer this Uniswap service. 

It starts with a transaction that creates a UTxO at this script address, here we call that *factory* for Uniswap factory. It contains an NFT that identifies the factory, 
the same trick that we have used a couple of times before, and as datum, it will contain the list of all liquidity pools.

So in the beginning, when the factory is just being created, that list will be empty.

Now let's assume that one user, Alice wants to create a liquidity pool for tokens A and B. A pool that allows others to swap A against B or B against A.

.. figure:: img/pic__00150.png

She has to provide some initial liquidity for the pool. So she needs some amount of token A and some amount of token B, let's say she has 1,000A and 2000B.

It's important to note here that the ratio between A and B reflects Alice's belief in the relative value of the tokens. So if she wants to set up a pool with 
1000A and 2000B, then she believes that one A has the same value as two Bs.

In order to create the liquidity pool, she will create a transaction with two inputs and three outputs.

.. figure:: img/pic__00151.png

The two inputs will be the liquidity she wants to provide; the 1000A and 2000B and the Uniswap factory invoked with the create redeemer. The three outputs 
will be the newly-created pool.

We call it *Pool AB* here to indicate that it contains tokens AB, which will contain the liquidity that Alice provided; the 1000A and the 2000B and a freshly-minted 
token that identifies this pool, an NFT, called *AB NFT* here.

The datum of the pool, the 1415, will be the amount of liquidity tokens that Alice receives in return for setting up this pool and providing the liquidity. #

If you wonder about the number, that is the square root of the product of 1000 and 2000, so that's how the initial amount of liquidity tokens is calculated. It 
doesn't really matter, you could scale it arbitrarily, but that's the way Uniswap does it.

The second output is the Uniswap factory again, with the same NFT as before that identifies it. And now the datum has been updated. So in this list that was 
empty before, the list of all liquidity pools, there is now an entry for the newly-created AB pool.

Finally, there's a third output for Alice, where she receives the freshly-minted liquidity tokens, called *AB* here to indicate that they belong to the pool AB.

Now that the liquidity pool has been set up, other users can use it to swap.

.. figure:: img/pic__00152.png

So let's assume that Bob wants to swap 100A against B. What will Bob do?

He will create a transaction that has two inputs and two outputs. The two inputs are the 100A he wants to swap, and the pool with the swap redeemer. The outputs 
are the Bs he gets in return.

In this example, that would be 181B and the updated pool. So the pool now has the additional 100A that Bob provided. So now it's 1,100A, and it has 181B fewer than before.

It still, of course, has the NFT that identifies the pool and the datum hasn't changed because the amount of liquidity tokens that have been minted hasn't changed.

Now, of course, the question is, where does this 181 come from? This is this ingenious idea, how price discovery works in Uniswap.

So the rule is roughly that the product of the amounts of the two tokens must never decrease. Initially we have 1000 As and 2000 Bs and the product is 2 million.

If you do the calculation, then you will see that after the swap 1100*1819 will be slightly larger than 2 million.

If you think about it or try a couple of examples by yourself, then you will see that in principle, you will always pay this ratio of the As and Bs in the pool, at least if you swap small amounts.

So originally the ratio from A to B was 1:2, 1000:2000. 100 is relatively small in comparison to the 1000 liquidity, so Bob should roughly get 200B, but he does get less
and there are two reasons for that.

One is that the amount of tokens in the liquidity pool is never allowed to go to zero. And the more of one sort you take out, the more expensive it gets - 
the less you get in return. So 100 depletes the pool a bit of As, so Bob doesn't get the full factor 2 out, he gets a little bit less out. That's exactly how this product formula works.

This also makes it ingenious, because it automatically accounts for supply and demand. If the next person also wants to swap 100A, they would get even less out.

The idea is if a lot of people want to put A in and want to get B in return, that means the demand for B is high. And that means the price of B in relation to A 
should rise. And that is exactly what's happening.

So the more people do a swap in this direction, put A in and get B out, the less of the gap because the price of B rises. If there were swaps in the other direction, 
you would have the opposite effect.

If there's an equal amount of swaps from A to B and B to A, then this ratio between the two amounts would stay roughly the same.

There's an additional reason why Bob doesn't get the full 200 that he might expect, and that is fees.

We want to incentivize Alice to set up the pool in the first place. She won't just do that for fun, she wants to profit from it, so she wants to earn on swaps that people make.

The original product formula is modified a bit to insist that the product doesn't only not decrease, but that it increases by a certain amount, a certain percentage, 
depending on how much people swap. That's 3% in this example of the 100A that Bob swaps, and it would be the same if you swap B instead.

This is basically added on top of this product, so anytime somebody swaps, not only does the product not decrease, it actually increases. And the more people swap, the more it increases.

The idea is that if Alice now would close the pool by burning her liquidity tokens, she gets all the remaining tokens in the pool and the product 
would be higher than what she originally put in.

So that's her incentive to set up the pool in the first place. 

The next operation we look at is the add operation where somebody supplies the pool with additional liquidity.

.. figure:: img/pic__00153.png

So let's say that Charlie also believes that the ratio from A to B should be 1:2 and he wants to contribute 400A and 800B.
He could also have tokens in a different ratio.
Basically the ratio reflects his belief in the true relative value of the tokens.
So Charlie wants to add 400 As and 800 Bs, and he creates a transaction
with two inputs and two outputs.
The inputs are the pool and his contribution, his additional liquidity
and the outputs are the updated pool where now his As and Bs have
been added to the pool tokens and note that now the datum has changed.
So we had 1,415 liquidity tokens before, and now we have 1,982, and
the difference the 567 go to Charlie.
So that's the second output of this transaction.
And that's the reward to Charlie for providing this liquidity,
this additional liquidity.
And there the formula is a bit complicated, but in principle,
it also works with the product.
So you check how much the product was before and after
the tokens have been added.
And you take into account, how many have already been minted?
And that also ensures that now basically Alice profits from the fees that Bob
paid with the swap and Charlie doesn't.
So this is taking into account, but the specific formula doesn't matter.
The idea is just that it's fair.
So people should receive liquidity tokens proportional to their contribution,
but, if they only add liquidity after a couple of swaps have already happened,
then they shouldn't profit from the fees that have accumulated in the meantime.
The next operation we look at is called removed and it allows owners of liquidity
tokens for a pool to burn some of them.

.. figure:: img/pic__00154.png

So in this example, let's assume that Alice wants to
burn all her liquidity tokens.
She could also keep some, she doesn't have to burn on, but in this example, she wants
to burn all her 1,415 liquidity tokens.
So for that, she creates another transaction with two inputs and
two outputs, the inputs are the liquidity token she wants to burn.
And of course the pool again with the remove redeemer.
And The outputs are the tokens from the pool that she receives
in return, so in this case, she would get 1078 A and 1,869 B.
And the updated pool is the second output.
So the 1078 A and 1,869 Bs have been removed from the pool and the datum has
been updated, so the 1,415 liquidity tokens that Alice burnt are now
subtracted from the 1,982 we had before.
And we see that 567 are remaining which are exactly those that Charlie owns.
And the formula for how many tokens Alice gets for burning liquidity
tokens, is again, somewhat complicated, but it's basically just proportional.
So we know how many liquidity tokens there are in total 1,982 from the datum.
And she basically just gets 1,415 over 1,982 of the pool.
And she gets the tokens in the ratio that they are in now.
So the 1072, 1,869 should be the same ratio as the 1,500 to 2,619.
So by burning, you don't change the ratio of the pool.
The last operation is close and it is for completely closing a pool and removing it.

.. figure:: img/pic__00155.png

And this can only happen when the last remaining liquidity tokens are burnt.
So in our example, Charlie holds all the remaining 567 liquidity tokens, and
therefore he can close down the pool.
And in order to do that, he creates a transaction with three inputs.
One is the factory and note that we only involve the factory when we created the
pool and now when we close it again, which also means that the contention
on the factory is not very high.
So the factory only gets involved when new pools are created, when pools are
closed down, but once they exist and as long as they are not closed, the
operations are independent of the factory.
But if you just need the factory, when we want to update the list
of existing pools, and by the way, this list is used to ensure that
there won't be duplicate pools.
So the create operation that we looked at in the beginning will fail if somebody
tries to create a pool that already exists for a pair of tokens that already exist.
So there will always for any given pair of tokens, be at most one pool
that country against those two tokens.
Okay, so let's go back to the close operation.
So the first input is the factory with the close redeemer, second the input
is the pool that we want to close.
And third input are all the remaining liquidity tokens, and we get two
outputs, one is the updated factory.
So in this case we only had one pool.
So the list only contains this one pool, and this is now removed from the
list, and the second output contains of all the remaining tokens, all the
tokens that were still in the pool by the time it gets closed down.
So the remaining liquidity tokens are burnt and Charlie gets all the
remaining tokens from the pool.

.. figure:: img/pic__00157.png


Code for Uniswap is actually part of the Plutus repository and it is in the Plutus
use cases library, and it split into four modules that are imported by the
Plutus dot contracts dot Uniswap module.
On-chain, off-chain, types and pool.
So as the names suggest:
on-chain contains the on-chain validation.
Off-chain contains the off-chain contracts.
Types contains common types that the other shares.
And pool contains the business logic, the calculations, how many liquidity tokens
the creator of a pool gets, how many tokens you get when you add liquidity
to a pool, how many tokens you get back when you burn liquidity tokens and
under which conditions a swap is valid.
So I don't want to go through all of that in too much detail.
It contains nothing we haven't talked about before, but let's
at least have a brief look.
So let's look at the types module first.
You represents the Uniswap coin, the one that identifies the factory

.. figure:: img/pic__00159.png


A and
B are used for pool operations where we have these two sorts of tokens inside
the pool,

.. figure:: img/pic__00160.png

pool state is the token that identifies a pool, actually in the
diagram earlier I said it's an NFT.
And by definition, NFT is something that only exists once actually here in the
implementation for each pool, an identical coin is created that identifies that pool.
So it's not strictly speaking NFT.
So all the liquidity pools have one coin of that sort

.. figure:: img/pic__00161.png

and liquidity
is used for the liquidity tokens that the liquidity providers gets.

.. figure:: img/pic__00162.png

And all these types are then used in the coin A type.
So A is a type parameter, that's a so-called Phantom type.
So that means it has no representation at run time.
It's just used to not mix up the various coins to make it easier to see what goes
where, so in the datum, a coin is simply an asset class that we have seen before.
So asset class recall is a combination of currency symbol and token name.

.. figure:: img/pic__00163.png

then amount is just a wrapper around integer that also contains
such a Phantom type parameter, so that we don't confuse amounts for
token A and token B for example.

.. figure:: img/pic__00164.png

Then we have some helper functions, constructing a
value from coin and the amount.
And here, for example, we see the use of this Phantom type, that's actually a
common trick in Haskell because now if you have, for example, pool operations
that has two different coins and two different amounts for the different coins.
And if the one is tag with this type capital A and the other with capital
B, then normally one could easily confuse them and somehow do operations
with the one coin, with the amount for the other, and then make a mistake.
And here the type system enforces that we don't do that.
So we can only use this value of function, for example, if we a coin and
the amount with the same tag type tag.
So as I said, that's a common trick in Haskell that some lightweight type
level programming that is doesn't need any fancy GHC extensions.
Unit Value creates one amount of the given coin.
Is unity checks whether this coin is contained in the value exactly once,
then amount checks how often the coin is contained in the value, and
finally make coin turns a currency symbol into a token name, into a coin.

.. figure:: img/pic__00165.png

And we have the Uniswap type which identifies the instance of the
Uniswap system we are running.
So of course, nobody can stop anybody from setting up a competing Uniswap system with
the competing factory, but the value of this type identifies a specific system.
And all the operations that are specific to pool will be parameterized
by a value of this type, but it's just a wrapper around the coin U.
And that is just the NFT that identifies the factory.

.. figure:: img/pic__00166.png

Then we have a type for liquidity pools, and that is basically just
two coins, the two coins in there.

However, there is one slight complication, only the two types
of tokens inside the pool matter.

.. figure:: img/pic__00167.png

Not the order, there is no first or second token, a pool that has coin
A, A and coin B, B should be the same as one where A and B are swapped.
And in order to achieve that, the eq instance has a special implementation.
So it's not the standard, we don't just compare if we want to compare two
liquidity pools, we don't just compare the first field with the first field of
other, and the second with the second, but we also try the other way round.
So liquidity pool tokens AB would be the same as liquidity pool with tokens BA.
So that's the only slight complication here.

.. figure:: img/pic__00168.png

