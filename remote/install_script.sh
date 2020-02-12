#! /bin/bash
sudo apt-get update -y
sudo apt-get install -y apache2
sudo systemctl start apache2
sudo systemctl enable apache2
echo "<h1>Deployed via Terraform</h1>" | sudo tee /var/www/html/index.html

sudo apt-get install -y python3.7
sudo apt-get install -y python-pip
sudo apt-get install -y python3-pip
update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.7 1

curl -O https://bootstrap.pypa.io/get-pip.py
python3 get-pip.py --user
sudo apt-get install -y awscli
pip3 install awscli --upgrade --user
sudo apt-get install -y postgresql-client
sudo apt-get install -y jq

export PGPASSWORD='${db_password}'
export SECRETID='${secret_id}'

wget "${db_ca_cert_url}" -o "/${db_ca_pem_file}"
chmod 777 "/${db_ca_pem_file}"

psql -h "${db_host}" -p "${db_port}" -d "${db_name}" -U "${db_user}" -c "DROP ROLE ${db_ro_only_role};"
psql -h "${db_host}" -p "${db_port}" -d "${db_name}" -U "${db_user}" -c "DROP ROLE ${db_rw_only_role};"

psql -h "${db_host}" -p "${db_port}" -d "${db_name}" -U "${db_user}" -c "CREATE ROLE ${db_ro_only_role};"
psql -h "${db_host}" -p "${db_port}" -d "${db_name}" -U "${db_user}" -c "CREATE ROLE ${db_rw_only_role};"

psql -h "${db_host}" -p "${db_port}" -d "${db_name}" -U "${db_user}" -c "DROP USER ${db_ro_only_user};"
psql -h "${db_host}" -p "${db_port}" -d "${db_name}" -U "${db_user}" -c "CREATE USER ${db_ro_only_user} WITH LOGIN;"
psql -h "${db_host}" -p "${db_port}" -d "${db_name}" -U "${db_user}" -c "GRANT rds_iam to ${db_ro_only_user};"
psql -h "${db_host}" -p "${db_port}" -d "${db_name}" -U "${db_user}" -c "GRANT ${db_ro_only_role} to ${db_ro_only_user};"

psql -h "${db_host}" -p "${db_port}" -d "${db_name}" -U "${db_user}" -c "DROP USER ${db_rw_only_user};"
psql -h "${db_host}" -p "${db_port}" -d "${db_name}" -U "${db_user}" -c "CREATE USER ${db_rw_only_user} WITH LOGIN;"
psql -h "${db_host}" -p "${db_port}" -d "${db_name}" -U "${db_user}" -c "GRANT rds_iam to ${db_rw_only_user};"
psql -h "${db_host}" -p "${db_port}" -d "${db_name}" -U "${db_user}" -c "GRANT ${db_rw_only_role} to ${db_rw_only_user};"

psql -h "${db_host}" -p "${db_port}" -d "${db_name}" -U "${db_user}" -c "DROP USER ${db_iam_db_user};"
psql -h "${db_host}" -p "${db_port}" -d "${db_name}" -U "${db_user}" -c "CREATE USER ${db_iam_db_user} WITH LOGIN;"
psql -h "${db_host}" -p "${db_port}" -d "${db_name}" -U "${db_user}" -c "GRANT rds_iam to ${db_iam_db_user};"

psql -h "${db_host}" -p "${db_port}" -d "${db_name}" -U "${db_user}" -f sql/${grant_access_template}
