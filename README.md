# terraform-rds-iam-access
Creating a FULL Architecture in AWS to perform a POC on RDS IAM Access

## Creating the Infrastructure

Run the following commands:
```
  $ terraform init
  $ terraform apply -auto-approve -var-file=terraform.dev.tfvars
```
Change the file terraform.dev.tfvars as per your liking. Terraform will kick in and create the resources in AWS.
```
...
aws_security_group_rule.default_can_talk_locally: Creation complete after 1s [id=sgrule-1908105406]
aws_security_group_rule.default_can_talk_to_the_world: Creation complete after 3s [id=sgrule-3447834296]
aws_security_group_rule.default_allow_all_local: Creation complete after 4s [id=sgrule-2671962417]
...
...
```

## Gennrate Authentication Token
SSH into the bastion host created and run the following commands:
```
~$ export RDSHOST=ooh-poc-dev-mhniy-db.xxxxxxxxxx.ap-southeast-1.rds.amazonaws.com
~$ export PGPASSWORD=$(aws rds generate-db-auth-token --hostname $RDSHOST --port 5432 --region ap-southeast-1 --username iam_rds_user)
```
This will generate a TOKEN ($PGPASSWORD) that will be used as the database password for user `iam_rds_user`.

## Connect
There are two ways to connect to the db:
* Through the Linux Bastion Box
* Through a DB Client installed on the User Machine. The DB Client (UI) will still need to `ssh` TUNNEL through the Bastion Box.

### Connect through EC2
* Connect through SSH into the Bastion Box
* Generate the Authentication Token as describe above
* Use psql (the RDS instance created is a POSTGRES DB). Run the command below:
```
~$ psql -h $RDSHOST -p 5432 "dbname=otp_poc user=iam_rds_user sslrootcert=rds-combined-ca-bundle.pem sslmode=verify-ca"
```
This will connect you to the DB in Terminal Mode
```
psql (10.10 (Ubuntu 10.10-0ubuntu0.18.04.1), server 11.5)
WARNING: psql major version 10, server major version 11.
         Some psql features might not work.
SSL connection (protocol: TLSv1.2, cipher: ECDHE-RSA-AES256-GCM-SHA384, bits: 256, compression: off)
Type "help" for help.

otp_poc=>
```
### Connect through a DB CLient (UI)
* Setup your DB Client to TUNNEL via SSH
* Configure the HOST, DATABASE and USER (iam_rds_user)
* Run the Generate Token and COPY the TOKEN Generated
* Paste the TOKEN into the PASSWORD Configuration and then CONNECT
```
Connected (3869 ms)
PostgreSQL 11.5
PostgreSQL 11.5 on x86_64-pc-linux-gnu, compiled by gcc (GCC) 4.8.3 20140911 (Red Hat 4.8.3-9), 64-bit
```


## References
* https://aws.amazon.com/premiumsupport/knowledge-center/users-connect-rds-iam/
* https://aws.amazon.com/blogs/database/securing-amazon-rds-and-aurora-postgresql-database-access-with-iam-authentication/
