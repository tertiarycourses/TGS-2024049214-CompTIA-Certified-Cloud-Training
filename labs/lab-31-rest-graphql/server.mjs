import { createYoga, createSchema } from "graphql-yoga"
import { createServer } from "node:http"
const yoga = createYoga({ schema: createSchema({
  typeDefs: `type Query { hello(name: String): String }`,
  resolvers: { Query: { hello: (_,a)=>"Hello "+(a.name||"cloud") } }
})})
createServer(yoga).listen(4000)
