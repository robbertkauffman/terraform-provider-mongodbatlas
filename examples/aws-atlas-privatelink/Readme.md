# Atlas Terraform Provider Example: PrivateLink - AWS

This example sets up a PrivateLink connection between your AWS VPC and your MongoDB Atlas Project. Optionally, it can also provision a jumphost to verify connectivity from AWS to the Atlas cluster over PrivateLink.

It deploys the following resources:
- AWS VPC, Internet Gateway, Route Tables, Subnets with public and private access
- VPC/Private Endpoint in AWS VPC
- PrivateLink Service in MongoDB Atlas Project
- PrivateLink connection from AWS Private Endpoint to PrivateLink Service in MongoDB Atlas
- Optional: MongoDB Atlas cluster (M10)
- Optional: jumphost on AWS EC2

## Usage

1. Set your Atlas public & private API key via environment variables:

        $ export MONGODB_ATLAS_PUBLIC_KEY="xxxxxxxx"
        $ export MONGODB_ATLAS_PRIVATE_KEY="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxx"

2. Set your AWS access key & secret via environment variables:

        $ export AWS_ACCESS_KEY_ID="xxxxxxxxxxxxxxxxxxxx"
        $ export AWS_SECRET_ACCESS_KEY="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

3. Initialize Terraform: `terraform init`

4. Specify any of the optional deployments:
  - If you want to use an existing Atlas cluster, comment all lines in *atlas-cluster.tf*
  - If you do NOT want to deploy a jumphost, comment all lines in *aws-jumphost.tf*
    - If you need access to the jumphost over SSH instead of via the AWS web console (EC2 Instance Connect), then you can add your SSH key via the *jumphost_ssh_key* variable

4. Run Terraform *apply* and supply values for any of the variables when prompted: `terraform apply`

5. Once Terraform is finished provisioning the resources, it should output the Atlas Private Endpoint connection string:
        
        atlas_pe_connstring = "mongodb+srv://cluster-atlas-pl-0.zywgx.mongodb.net"

Follow the steps in the next section if you want to verify connectivity from the AWS jumphost to the Atlas cluster.

6. Once you finished your testing, ensure you destroy the resources to avoid unnecessary charges: `terraform destroy`

## Connecting from jumphost

1. Get the connection string from either the *terraform apply* output or the Atlas UI.

2. Connect to the AWS jumphost via SSH or the AWS Console (EC2 Instance Connect).

3. Install *netcat* by running: `sudo yum install -y nc`

4. Resolve the connection string to a list of hostnames by prepending the hostname of the connection string with *_mongodb._tcp*:

        $ nslookup -q=SRV _mongodb._tcp.cluster-atlas-pl-0.zywgx.mongodb.net
        Server:         127.0.0.1
        Address:        127.0.0.1#53

        Non-authoritative answer:
        _mongodb._tcp.cluster-atlas-pl-0.zywgx.mongodb.net      service = 0 0 1043 pl-0-us-west-2.zywgx.mongodb.net.
        _mongodb._tcp.cluster-atlas-pl-0.zywgx.mongodb.net      service = 0 0 1041 pl-0-us-west-2.zywgx.mongodb.net.
        _mongodb._tcp.cluster-atlas-pl-0.zywgx.mongodb.net      service = 0 0 1042 pl-0-us-west-2.zywgx.mongodb.net.

5. The command of the previous step should return a list of hostnames: the Atlas cluster nodes. Verify connectivity to any of the nodes with *netcat* and the hostname and port of the Atlas node:

        $ nc -zv -w 5 pl-0-us-west-2.zywgx.mongodb.net 1041
        Ncat: Version 7.50 ( https://nmap.org/ncat )
        Ncat: Connected to 10.0.1.76:1039.
        Ncat: 0 bytes sent, 0 bytes received in 0.01 seconds.

6. If the previous step times out, double check that the network security group is allowing access to the private endpoint over the ports that Atlas is using. If it succeeds, you can try connecting to the cluster using [mongosh](https://www.mongodb.com/docs/mongodb-shell/install/).

## Network security group configuration

The following network access to and from the PE is required:
- Allow inbound access over TCP for ports 1024-65535 (see note on ports below) to any IPs (e.g. application, jumphost) or subnets that will connect to the PE.
- Allow outbound access over TCP from the PE to (all) subnet(s) and all ports.

MongoDB theoretically can use any port between 1024-65535. In practice, ports above 2000 are rarely used. The number of clusters and nodes for each cluster drive up the port range, and also cluster deletion and (re)creation as old ports are not always recycled.

The network security group of this example allows access over ports 1024-1074, which should work for most small test clusters. Please adjust the port range when using an existing cluster that uses ports outside this range, by editing lines 54-55 of *aws-vpc.tf*.
