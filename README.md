# Cloud Runner

Cloud Runner creates a new VM somewhere in the cloud and
runs a single script against it.

Exit code correctly propagates.


## Installation

    gem install cloud_runner


## DigitalOcean Cloud

Uses `https://www.digitalocean.com/api` for creating new
droplets (VM) and associating ssh keys.

Run script against new droplet:

    cr-new                  \
      --client-id CID       \
      --app-key APP_KEY     \
      --script something.sh

Run script against existing droplet:

    cr-over                     \
      --client-id CID           \
      --app-key APP_KEY         \
      --droplet-id DROPLET_ID   \
      --ssh-key SSH_KEY         \
      --script something.sh
