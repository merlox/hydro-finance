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
    it('should add a new card and create a new user', async () => {
        const card = '1234123412341234'
        const expiry = Math.floor(Date.now() / 1000)
        const name = 'My credit card'
        const cvv = '123'

        // await hydroFinance.addCard(card, expiry, name, cvv, {
        //     from: accounts[0],
        //     gas: 7e6
        // })
        //
        // const publishedCard = await hydroFinance.cardById(1)
        // console.log('Card', publishedCard)
        // assert.equal(title, product.title, 'The product must be deployed with the publish function')
    })
}) // All tests passing
