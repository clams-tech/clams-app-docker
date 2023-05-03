#!/usr/bin/env python3
import json
from pyln.client import  Plugin, RpcError, LightningRpc, Millisatoshi
plugin = Plugin()

@plugin.init() # Decorator to define a callback once the `init` method call has successfully completed
def init(options, configuration, plugin, **kwargs):
    plugin.log("Plugin prism.py initialized")

@plugin.method("prism")
def prism(plugin, label, members):
    try:
        #todo validate the members list as [{"name": "alias", "destination": "pubkey", "amount": number}]

        # Define the expected keys
        expected_keys = {"argument_label", "members"}

        # Define the string to validate
        plugin.log('inside prism')
        lrpc =  LightningRpc("/root/.lightning/regtest/lightning-rpc")
        offer = lrpc.offer("any", "label")
        lrpc.datastore(offer["bolt12"],
                       string=json.dumps({"label":label, "members":members}))
        return offer
    except RpcError as e:
        plugin.log(e)
        return e

plugin.add_option('destination', 'destination', 'default_destination')


@plugin.subscribe("connect")
def on_connect(plugin, id, address, **kwargs):
    plugin.log("Received connect event for peer {}".format(id))


@plugin.subscribe("disconnect")
def on_disconnect(plugin, id, **kwargs):
    plugin.log("Received disconnect event for peer {}".format(id))

@plugin.subscribe("invoice_payment")
def on_payment(plugin, invoice_payment, **kwargs):
    plugin.log("Received invoice_payment event for label {label}, preimage {preimage},"
               " and amount of {msat}".format(**invoice_payment))
    plugin.log(invoice_payment)
    # we will check if bolt12 we stored earlier in the prism call is in the label of the bolt11 invoice
    # at that point keysend pubkeys in the members
    lrpc =  LightningRpc("/root/.lightning/regtest/lightning-rpc")
    expected_keys = {"destination", "pubkey", "amount"}

    #check datastore 
    datastore = lrpc.listdatastore(invoice_payment)
    parsed_dict = json.loads(datastore)
    members_dict = parsed_dict.get("members", {})

    # Check that the "members" object has the required keys
    if set(members_dict.keys()) == expected_keys:
        # Iterate over the properties in the "members" object
        for key, value in members_dict.items():
            print(f"{key}: {value}")
            lrpc.keysend(destination=value["destination"], amount_msat=Millisatoshi(value["amount"]))

    return invoice_payment

plugin.run() # Run our plugin