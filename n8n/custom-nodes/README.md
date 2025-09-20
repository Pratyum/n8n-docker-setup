# Custom n8n Nodes Directory

This directory is mounted into the n8n container at `/home/node/.n8n/custom`.

## Installing Custom Nodes

1. Place custom node packages in this directory
2. Restart n8n container: `./n8n-ctl.sh restart`

## Example Structure

```
custom-nodes/
├── @n8n/n8n-nodes-custom/
│   ├── package.json
│   ├── nodes/
│   └── credentials/
└── my-custom-node/
    ├── package.json
    └── MyCustomNode.node.js
```

## Installing from npm

You can also install nodes directly into the running container:

```bash
# Access n8n container
docker exec -it n8n /bin/sh

# Install a custom node
npm install n8n-nodes-telegram -g

# Restart n8n
exit
./n8n-ctl.sh restart
```

For more information, see: https://docs.n8n.io/integrations/community-nodes/