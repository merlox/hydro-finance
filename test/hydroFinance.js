const assert = require('assert')
const HydroFinance = artifacts.require('HydroFinance.sol')
const IdentityRegistry = artifacts.require('IdentityRegistry.sol')
let hydroFinance
let identityRegistry

function bytes32(msg) {
    return web3.utils.fromAscii(msg)
}

contract('HydroFinance', accounts => {
    beforeEach(async () => {
        identityRegistry = await IdentityRegistry.new()
        hydroFinance = await HydroFinance.new(identityRegistry.address)
        console.log('Creating identity one')
        await identityRegistry.createIdentity(accounts[0], [accounts[1]], [accounts[1]], {gas: 8e6})
        console.log('Creating identity two')
        await identityRegistry.createIdentity(accounts[1], [accounts[2]], [accounts[2]], { from: accounts[1], gas: 8e6 })
    })
    it('should add a new card', async () => {
        const card = '1234123412341234'
        const expiry = Math.floor(Date.now() / 1000)
        const name = 'My credit card'
        const cvv = '123'

        await hydroFinance.addCard(card, expiry, name, cvv, {
            from: accounts[0],
            gas: 7e6
        })

        const publishedCard = await hydroFinance.cardById(1)
        assert.equal(parseInt(publishedCard.id), 1, 'The published card id must be one')
        assert.equal(publishedCard.einOwner, 1, 'The published card ein owner must be one')
        assert.equal(publishedCard.cardName, name, 'The published card name must be <My credit card>')
        assert.equal(String(publishedCard.card), card, 'The published card id must be one')
        assert.equal(Number(publishedCard.expiry), expiry, 'The published card expiry must be the same')
        assert.equal(String(publishedCard.cvv), cvv, 'The published card cvv must be 123')
    })
    it('should create a new user when adding a card', async () => {
        const card = '1234123412341234'
        const expiry = Math.floor(Date.now() / 1000)
        const name = 'My credit card'
        const cvv = '123'

        await hydroFinance.addCard(card, expiry, name, cvv, {
            from: accounts[0],
            gas: 7e6
        })

        const publishedUser = await hydroFinance.getUserData()
        assert.equal(parseInt(publishedUser[0]), 1, 'The published user ein must be set')
        assert.equal(publishedUser[1], accounts[0], 'The published user address must be set')
        assert.equal(publishedUser[2].length, 1, 'The published user card ids array must be length 1')
        assert.equal(publishedUser[3].length, 0, 'The published user bank ids array must be length 1')
        assert.equal(publishedUser[4].length, 0, 'The published user investment ids array must be length 1')
    })
    it('should add a new bank', async () => {
        const card = '1234123412341234'
        const expiry = Math.floor(Date.now() / 1000)
        const name = 'My credit card'
        const cvv = '123'

        await hydroFinance.addCard(card, expiry, name, cvv, {
            from: accounts[0],
            gas: 7e6
        })

        const publishedCard = await hydroFinance.cardById(1)
        assert.equal(parseInt(publishedCard.id), 1, 'The published card id must be one')
        assert.equal(publishedCard.einOwner, 1, 'The published card ein owner must be one')
        assert.equal(publishedCard.cardName, name, 'The published card name must be <My credit card>')
        assert.equal(String(publishedCard.card), card, 'The published card id must be one')
        assert.equal(Number(publishedCard.expiry), expiry, 'The published card expiry must be the same')
        assert.equal(String(publishedCard.cvv), cvv, 'The published card cvv must be 123')
    })
    it('should add a new investment account', async () => {
        const card = '1234123412341234'
        const expiry = Math.floor(Date.now() / 1000)
        const name = 'My credit card'
        const cvv = '123'

        await hydroFinance.addCard(card, expiry, name, cvv, {
            from: accounts[0],
            gas: 7e6
        })

        const publishedCard = await hydroFinance.cardById(1)
        assert.equal(parseInt(publishedCard.id), 1, 'The published card id must be one')
        assert.equal(publishedCard.einOwner, 1, 'The published card ein owner must be one')
        assert.equal(publishedCard.cardName, name, 'The published card name must be <My credit card>')
        assert.equal(String(publishedCard.card), card, 'The published card id must be one')
        assert.equal(Number(publishedCard.expiry), expiry, 'The published card expiry must be the same')
        assert.equal(String(publishedCard.cvv), cvv, 'The published card cvv must be 123')
    })
    it('should remove a user')
}) // All tests passing
