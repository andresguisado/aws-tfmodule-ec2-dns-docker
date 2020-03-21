# Terraform Module: aws-tfmodule-ec2-docker 

Terraform module to a Centos7 instance with Docker CE and docker-compose in an Amazon VPC subnet with an AWS secrutity group allowing only our current public IP to access SSH(22) and HTTPS(443.

In addition, a public DNS record is created in a given domain zone.

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
  source              = "git::git@github.com:andresguisado/aws-tfmodule-ec2-docker.git"
  client_name         = "${var.client_name}"
  product             = "${var.product}"
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

## AWS AMI Used

**AWS AMI**|**Description**|**ssh-user**|**owner**
-----|-----|-----|-----
CentOS Linux 7 x86_64 HVM EBS ENA 1901_01-b7* | Centos7 | centos | 679593333241

## Outputs

**Output name**|**Description**
-----|-----
**public_url**  | Public dns for ec2

Authors
=======
Originally created by [Andres Guisado](https://www.linkedin.com/in/andresguisado/)



