source cm-env.sh

rm -rf inventory.txt
rm -rf *inventory*

gcloud compute instances delete vm-a --zone=$ZONE --quiet
gcloud compute instances delete vm-b --zone=$ZONE --quiet
gcloud compute instances delete vm-c --zone=$ZONE --quiet