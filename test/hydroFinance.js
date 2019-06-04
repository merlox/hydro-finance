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
        await identityRegistry.createIdentity(accounts[0], [accounts[1]], [accounts[1]], {gas: 8e6})
        await identityRegistry.createIdentity(accounts[1], [accounts[2]], [accounts[2]], { from: accounts[1], gas: 8e6 })
    })
    it('should add a new card', async () => {
        const card = '1234123412341234'
        const expiry = Math.floor(Date.now() / 1000)
        const name = 'My credit card'
        const cvv = '123'
        const ein = 1

        await hydroFinance.addCard(card, expiry, name, cvv, {
            from: accounts[0],
            gas: 7e6
        })
        const encryptedCard = web3.utils.soliditySha3(ein, name, card, expiry, cvv)
        const checkResult = await hydroFinance.checkCard(encryptedCard, name, card, expiry, cvv)
        const user = await hydroFinance.getUserData()

        assert.ok(checkResult, 'The published card must be valid')
        assert.equal(user[2][0], encryptedCard, 'The user must have the new card added')
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
        assert.equal(publishedUser[2].length, 1, 'The published user encrypted cards array must be length 1')
        assert.equal(publishedUser[3].length, 0, 'The published user encrypted banks array must be length 1')
        assert.equal(publishedUser[4].length, 0, 'The published user encrypted investments array must be length 1')
    })
    it('should add a new bank', async () => {
        const bank = '1234123412341234'
        const name = 'My own bank'
        const ein = 1

        await hydroFinance.addBank(bank, name, {
            from: accounts[0],
            gas: 7e6
        })
        const encryptedBank = web3.utils.soliditySha3(ein, bank, name)
        const checkResult = await hydroFinance.checkBank(encryptedBank, bank, name)
        const user = await hydroFinance.getUserData()

        assert.ok(checkResult, 'The published bank must be valid')
        assert.equal(user[3][0], encryptedBank, 'The user must have the new bank added')
    })
    it('should add a new investment account', async () => {
        const investment = '1234123412341234'
        const name = 'My investment account'
        const ein = 1

        await hydroFinance.addInvestmentAccount(investment, name, {
            from: accounts[0],
            gas: 7e6
        })
        const encryptedInvestment = web3.utils.soliditySha3(ein, investment, name)
        const checkResult = await hydroFinance.checkInvestment(encryptedInvestment, investment, name)
        const user = await hydroFinance.getUserData()

        assert.ok(checkResult, 'The published investment must be valid')
        assert.equal(user[4][0], encryptedInvestment, 'The user must have the new investment added')
    })
    it('should remove a user', async () => {
        // Add a bank to create a new user
        const bank = '1234123412341234'
        const name = 'My own bank'
        await hydroFinance.addBank(bank, name, {
            from: accounts[0],
            gas: 7e6
        })

        await hydroFinance.removeAccount({
            from: accounts[0],
            gas: 7e6
        })
        try {
            await hydroFinance.users(0)
            assert.ok(false, 'The transaction should revert')
        } catch(e) {
            assert.ok(true, 'The transaction should revert since there arent any more users')
        }
    })
}) // All tests passing
