use shop
db.customers.insertOne({email:"a@x.com", name:"Alice", orders:[
  {amount: 12.50, item:"pen"},
  {amount: 99.00, item:"chair"}
]})
db.customers.insertOne({email:"b@x.com", name:"Bob", orders:[
  {amount: 5.00, item:"pad"}
]})

db.customers.aggregate([
  {$unwind:"$orders"},
  {$group:{_id:"$name", total:{$sum:"$orders.amount"}}}
])
