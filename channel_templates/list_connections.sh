#!/bin/bash

# this script will output the connection and channels within our lightning network

# for each node we want to list its connections and check if we have channels with them
    # each node will output:
        #  { nodealias: { connections: [{node_alias: string, has_channels: bool}] } }
    
    #we might also want to include channel info, to know how they are balanced


