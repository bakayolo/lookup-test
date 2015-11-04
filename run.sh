#!/bin/sh 

time=$(date +"%y%m%d%H%M")
DBNAME="lookup-test-sh-$time"
HOST="localhost:27017"

echo "Current server version"
mongo --host $HOST --eval 'printjson(db.version())'

echo "Let's import the dataset"

echo "Import crimes.json"
mongoimport -d $DBNAME -c crimes --host $HOST < crimes.json
echo "Import departements"
mongoimport -d $DBNAME -c departements --host $HOST < departements.json

echo "Create Indexes"
mongo --host $HOST --eval "printjson(db.crimes.createIndex({'lieu': 1}))" $DBNAME
mongo --host $HOST --eval "printjson(db.departements.createIndex({'nom': 1}))" $DBNAME

echo "Run \$lookup aggregation"
pipeline="[{ \$lookup:{ from: 'departements', localField: 'lieu', foreignField:'nom', as:'departement'}}]"
mongo --host $HOST --eval "printjson( db.runCommand({ 'aggregate': 'crimes', 'pipeline': $pipeline, 'explain': true, 'cursor': {'batchSize': 1} } )   )" $DBNAME

if [[ -n $1 && $1 = 'k' ]]
then
    echo "Keeping the database"
else
    echo "Dropping database"
    mongo --host $HOST --eval "printjson(db.dropDatabase())" $DBNAME
fi



