#! /bin/bash

########################################################################################################################
## This script is used by the catalog pipeline to deploy the  VPC, which is a prerequisite for the Private path       ##
## after catalog validation has complete.                                                                             ##
########################################################################################################################

set -e

DA_DIR="solutions/fully-configurable"
TERRAFORM_SOURCE_DIR="tests/resources"
JSON_FILE="${DA_DIR}/catalogValidationValues.json"
REGION="us-south"
TF_VARS_FILE="terraform.tfvars"

(
  cwd=$(pwd)
  cd ${TERRAFORM_SOURCE_DIR}
  echo "Provisioning prerequisite VPC .."
  terraform init || exit 1
  # $VALIDATION_APIKEY is available in the catalog runtime
  {
    echo "ibmcloud_api_key=\"${VALIDATION_APIKEY}\""
    echo "prefix=\"pp-$(openssl rand -hex 2)\""
    echo "region=\"${REGION}\""
  } >>${TF_VARS_FILE}
  terraform apply -input=false -auto-approve -var-file=${TF_VARS_FILE} || exit 1

  resource_group_name_var_name="existing_resource_group_name"
  resource_group_name_var_value=$(terraform output -state=terraform.tfstate -raw resource_group_name)
  existing_vpc_name="existing_vpc_crn"
  existing_vpc_value=$(terraform output -state=terraform.tfstate -raw vpc_crn)
  existing_subnet_id_var_name="existing_subnet_id"
  existing_subnet_id_var_value=$(terraform output -state=terraform.tfstate -raw existing_subnet_id)

  echo "Appending '${resource_group_name_var_name}' and '${existing_vpc_name}' input variable values to ${JSON_FILE}.."

  cd "${cwd}"
  jq -r --arg resource_group_name_var_name "${resource_group_name_var_name}" \
    --arg resource_group_name_var_value "${resource_group_name_var_value}" \
     --arg existing_vpc_name "${existing_vpc_name}" \
    --arg existing_vpc_value "${existing_vpc_value}" \
    --arg existing_subnet_id_var_name "${existing_subnet_id_var_name}" \
    --arg existing_subnet_id_var_value "${existing_subnet_id_var_value}" \
    '. + {($resource_group_name_var_name): $resource_group_name_var_value, ($existing_vpc_name): $existing_vpc_value, ($existing_subnet_id_var_name): $existing_subnet_id_var_value}' "${JSON_FILE}" >tmpfile && mv tmpfile "${JSON_FILE}" || exit 1

  echo "Pre-validation complete successfully"
)
