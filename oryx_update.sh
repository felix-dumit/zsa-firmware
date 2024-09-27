ORYX_HASH=NY75B

# git checkout main
# git branch -D dev &>/dev/null || true
# git checkout -b dev e3fd4797f4cf1c678b8cf0b3012b51ad84d2e989
git checkout oryx

output=$(curl --location 'https://oryx.zsa.io/graphql' --header 'Content-Type: application/json' --data '{"query":"query getLayout($hashId: String!, $revisionId: String!, $geometry: String) {layout(hashId: $hashId, geometry: $geometry, revisionId: $revisionId) {  revision { title, hashId  }}}","variables":{"hashId":"NY75B","geometry":"voyager","revisionId":"latest"}}' | jq '.data.layout.revision | [.title, .hashId]')

echo "OUTPUT: $output"
TITLE=$(echo "$output" | jq -r '.[0]')
HASH_ID=$(echo "$output" | jq -r '.[1]')

echo "Latest title: $TITLE"
echo "Latest hash: $HASH_ID"

curl -L "https://oryx.zsa.io/source/$HASH_ID" -o .latest_oryx_source.zip
rm -rf .wip_layout
unzip -oj .latest_oryx_source.zip '*_source/*' -d mylayout

git add .
git commit -a -m "[Oryx] $TITLE" -m "$HASH_ID"
# git checkout dev
git checkout main
git cherry-pick oryx --empty drop
