/**
 * Manapaho (https://github.com/Manapaho/)
 *
 * Copyright © 2016 Manapaho. All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE.txt file in the root directory of this source tree.
 */

import {
    GraphQLObjectType,
    GraphQLSchema,
    GraphQLList,
    GraphQLString,
    GraphQLNonNull,
    GraphQLInputObjectType
} from 'graphql';

const GraphQLInputParam = new GraphQLInputObjectType({
    name: 'InputParam',
    fields: () => ({
        key: {type: GraphQLString},
        value: {type: GraphQLString}
    })
});

const GraphQLParam = new GraphQLObjectType({
    name: 'Param',
    fields: () => ({
        key: {type: GraphQLString},
        value: {type: GraphQLString}
    })
});

const GraphQLDataSet = new GraphQLObjectType({
    name: 'DataSet',
    fields: () => ({
        id: {type: GraphQLString},
        stuff: {type: GraphQLString},
        params: {type: new GraphQLList(GraphQLParam)}
    })
});

const Query = new GraphQLObjectType({
    name: 'MySchema',
    description: "Root of my Schema",
    fields: () => ({
        dataSet: {
            type: GraphQLDataSet,
            args: {
                params: {type: new GraphQLList(GraphQLInputParam)}
            },
            resolve: function (root, {params}) {
                return {
                    id: 'Identifier',
                    stuff: 'Some More Stuff',
                    params: params
                };
            }
        }
    })
});

const Schema = new GraphQLSchema({
    query: Query
});

export default Schema;