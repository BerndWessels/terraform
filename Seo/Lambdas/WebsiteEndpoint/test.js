const lambda = require('./.WebsiteEndpoint.compiled');

lambda.handler({},{done: (err, res)=> {
    console.log(err, res);
}});
