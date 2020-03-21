# Terraform Module: A Centos7 with docker on EC2 AWS 

**Description:** Terraform module to a Centos7 instance with Docker CE and docker-compose demo/poc usage. [Summon](https://cyberark.github.io/summon/) is used to fetch secrets from **Keychain** or **Conjur/DAP** and provide them to terraform.

**Output:** A Centos7 with Docker CE and docker-compose on an EC2 instance in an Amazon VPC subnet.

## Project Structure

```bash
|-- main.tf
|-- vpc.tf
|-- workstation-external-ip.tf
|-- outputs.tf
|-- terraform.sh
|-- variables.tf
```
### File Descriptions

**Filename**|**Description**
-----|-----
[main.tf](main.tf) | EC2 declaration. 
[vpc.tf](vpc.tf) | Networking configuration.
[workstation-external-ip.tf](workstation-external-ip.tf) | (Optional)To fetch the external IP of your local workstation to configure inbound EC2 Security Group access to the Kubernetes cluster.
[outputs.tf](outputs.tf) | Output definitions, to enable consumption of resources by other projects and modules. Keep this up to date with any additional resources created via the project.
[terraform.sh](terraform.sh) | Wrapper script which runs terraform init to setup remote state, reading env vars if present to override default names/locations. Once the init has been performed it then makes a regular call to terraform, passing through all parameters verbatim.
[variables.tf](variables.tf) | Variable initialisation.


## Module Usage

```
module "aws_ec2_docker" {
  client_name         = "git::ssh://git@github.com:andresguisado/aws-tfmodule-ec2-docker.git"
  product             = "${var.porduct}"
  environment         = "${var.environment}"
  region              = "${var.region}"
  instance_type       = "${var.instance_type}"
  subnet              = "${var.subnet}"
  ssh_key_name        = "${var.ssh_key_name}"
  r53_zoneid_public   = "${var.r53_zoneid_public}"
  dns_public_name     = "${var.dns_public_name}"
}
```

## AWS Requirements

- Creating AWS S3 Bucket in advanced as follows: ``` ${var.client_name}-terraform-state ```
- AWS EC2 SSH key access **uploaded in AWS in advanced**: ``` ${var.ssh_key_name} ```
- A domain in AWS Route53: ``` ${var.r53_zoneid_public} ```


# Terraform Usage 

## Requirements 
- Install Terraform
- Install AWS CLI
- Getting **AWS_API_KEY** and **AWS_API_SECRET** and put it in ``` example.tfvars ```
- Reviewing ``` example.tfvars** ```

### Apply

```bash
> ./terraform.sh apply -auto-approve -var-file="example.tfvars"
```

### Destroy

```bash
> ./terraform.sh destroy -auto-approve -var-file="example.tfvars"
```

# Summon Conjur/DAP Usage

## Requirements 
- Install Terraform
- Install AWS CLI
- [Install Summon](https://github.com/cyberark/summon#install)
- [Installing Summon Conjur provider](https://github.com/cyberark/summon-conjur#install)
- [Summon Configuration](https://github.com/cyberark/summon-conjur#configuration)
- Getting **AWS_API_KEY** and **AWS_API_SECRET**
- Reviewing **secrets.yml** according to secrets created in Conjur.

### Apply

```bash
> summon -p summon-conjur ./terraform.sh plan -out=tfplan.out

> summon -p summon-conjur ./terraform.sh apply -auto-approve tfplan.out
```

### Destroy

```bash
> summon -p summon-conjur ./terraform.sh plan -destroy -out=tfdestroyplan.out

> summon -p summon-conjur ./terraform.sh destroy -auto-approve 
```

# Summon Keyring Usage

## Requirements 
- Install Terraform
- Install AWS CLI
- [Install Summon](https://github.com/cyberark/summon#install)
- [Installing Summon Key Ring provider](https://github.com/cyberark/summon-keyring#install)
- Getting **AWS_API_KEY** and **AWS_API_SECRET**
- Reviewing **secrets.yml** according to secrets created in [Keyring](https://github.com/cyberark/summon-keyring#example).

### Apply

```bash
> summon -p ring.py ./terraform.sh plan -out=tfplan.out

> summon -p ring.py ./terraform.sh apply -auto-approve tfplan.out
```

### Destroy

```bash
> summon -p ring.py ./terraform.sh plan -destroy -out=tfdestroyplan.out

> summon -p ring.py ./terraform.sh destroy -auto-approve 
```

# Access

An tf output called **conjur_url** has been configured in order to access to conjur open the following URL in a browser:

```bash
> https://<conjur_url> 
```

Authors
=======
Originally created by [Andres Guisado](https://www.linkedin.com/in/andresguisado/)



