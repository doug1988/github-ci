# OpenVPN

## Resources

- Public Docker image with openvpn and scripts
- Task definition sets public ip for network interface
- As container starts
  - it updates DNS to point to its public ip

## Workspaces

- shared-ap-southeast-2-default

# Description openvpn stack deploy
- How to set up the openvpn stack  unsig make file.

## if is there env files - clean existing files
- rm -r .env .env.auth

# workspaces
- before execute the stack is necessary to set the correct workspace for each environment
1. shared-services: `export WORKSPACE=shared-ap-southeast-2-default`

## Executing open vpnstack
- once the correct workspace has been set up, execute the following process:

## 1. Google Authentication
- make google-auth

## 2. Assume role
- make dnx-assume

## 3. terraform init
- make init

## 4. terraform plan
- make plan

## 5. terraform apply
- make apply






# Usage

## Adding Users

1. Login to AWS Console
2. Switch to Shared Services account
3. Change to the region that OpenVPN is deployed
4. Go to Services -> Systems Manager -> Parameter Store
5. Find a parameter named `/openvpn-shared-services/USERS` click Edit
6. Add users separated by comma, as in example below:

Example:

```
allan,helder,claison,woltter
```

For DNX users, add `dnx-` prefix to avoid confusion with client's users.

**Do not remove users from the list, there's a revoking process described below.**

Commit the code and apply the changes in the pipeline.

## Revoking Users

There's no way to remove an user, since it's key already been signed by the OpenVPN certificate.

Instead, we have to revoke users.

To revoke, follow the steps:

1. Login to AWS Console
2. Switch to Shared Services account
3. Change to the region that OpenVPN is deployed
4. Go to Services -> Systems Manager -> Parameter Store
5. Find a parameter named `/openvpn-shared-services/REVOKE_USERS` click Edit
6. Add users separated by comma, as in example below:

```
"allan,claison"
```

Use the exact same name that is on `USERS` parameter. **There's no need to remove the revoked users from `USERS` parameter.**

## Applying Changes

After changing USERS or REVOKE_USERS parameter, wait for a few minutes and the OpenVPN container will automatically pick up and perform the changes.

You can follow the process by reading the logs at Cloudwatch Logs.

## OpenVPN Logs (debugging issues)

To view container logs, follow the steps below:

1. Login to AWS Console
2. Switch to Shared Services account
3. Change to the region that OpenVPN is deployed
4. Go to Cloudwatch and select Log Groups under Logs
5. Find a Log Group called `ecs-openvpn-shared-services` and click on it
6. Click "Search log group" at the top right corner

## Downloading OVPN files

When a user is added, OpenVPN copies a .ovpn file to an S3 bucket in the same account. This file needs to be sent to the user so he/she can connect to the VPN.

1. Login to AWS Console
2. Switch to Shared Services account
3. Go to S3
4. Find a bucket called `openvpn-shared-services-<a long number>`
5. Click on the bucket
6. Download the .opvn files as needed

**It's important that .ovpn files are not shared between users. Sharing will cause connections to be dropped as one user can maintain only one connection at a time.**
