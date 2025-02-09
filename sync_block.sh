#!/bin/bash
KROMA_DB_PATH=/.kroma/db/geth
SNAPSHOT_PATH=.snapshot_$(date +%s | base64 | cut -c 1-10)
SNAPSHOT_ORIGIN=https://snapshot.sepolia.kroma.network/latest/snapshot.tar.gz

mkdir -p ${SNAPSHOT_PATH}
wget -P ./${SNAPSHOT_PATH} ${SNAPSHOT_ORIGIN}
tar xvzf ${SNAPSHOT_PATH}/snapshot.tar.gz -C ${SNAPSHOT_PATH}/
rm -rf ${SNAPSHOT_PATH}/snapshot.tar.gz ${SNAPSHOT_PATH}/nodekey

docker stop kroma-node

docker exec -it kroma-geth sh -c "mv ${KROMA_DB_PATH}/nodekey ../nodekey"
docker exec -it kroma-geth sh -c "rm -rf ${KROMA_DB_PATH}/*"
docker exec -it kroma-geth sh -c "mv ../nodekey ${KROMA_DB_PATH}/nodekey"

docker cp ${SNAPSHOT_PATH}/. kroma-geth:${KROMA_DB_PATH}/
rm -rf ${SNAPSHOT_PATH}

docker restart kroma-geth
sleep 5
docker start kroma-node
