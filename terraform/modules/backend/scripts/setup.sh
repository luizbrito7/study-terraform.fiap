#!/bin/bash

# colors
COLOR_DEFAULT="\e[0m"
COLOR_BLUE="\e[1;34m"
COLOR_GREEN="\e[1;32m"
COLOR_RED="\e[1;31m"
COLOR_YELLOW="\e[1;33m"

# utility functions
log_info() { echo -e "${COLOR_BLUE}$1${COLOR_DEFAULT}"; }
log_success() { echo -e "${COLOR_GREEN}$1${COLOR_DEFAULT}"; }
log_error() { echo -e "${COLOR_RED}$1${COLOR_DEFAULT}"; }
log_warn() { echo -e "${COLOR_YELLOW}$1${COLOR_DEFAULT}"; }

check_exit_code() {
    if [ $1 -ne 0 ]; then
        log_error "$2 failed, exit code: $1"
        exit 1
    else
        log_success "$2 success"
    fi
}

# variables
GH_ACCESS_TOKEN="${1}"

# auth env
export GH_TOKEN="$GH_ACCESS_TOKEN"

if gh variable list --repo "${GITHUB_REPOSITORY}" | grep -q "AWS_BUCKET_TFSTATE_ID"; then
	log_success "Variable AWS_BUCKET_TFSTATE_ID existe no repositório."
	BUCKET_NAME=$(gh variable --repo "${GITHUB_REPOSITORY}" get AWS_BUCKET_TFSTATE_ID)
	echo "AWS_BUCKET_TFSTATE_ID=$BUCKET_NAME" >> $GITHUB_OUTPUT
else
	log_warn "Variable AWS_BUCKET_TFSTATE_ID NÃO existe, criando backend remoto..."

	# Terraform commands
	log_info "Inicializando Terraform..."
	terraform -chdir=./terraform/modules/backend init
	check_exit_code $? "Terraform init"
	
	log_info "Executando Terraform plan..."
	terraform -chdir=./terraform/modules/backend plan -out tfplan
	check_exit_code $? "Terraform plan"
	
	log_info "Executando Terraform apply..."
	terraform -chdir=./terraform/modules/backend apply tfplan
	check_exit_code $? "Terraform apply"

	# Capture output and create variable
	log_info "Capturando nome do bucket..."
	BUCKET_NAME=$(terraform -chdir=./terraform/modules/backend output -raw bucket_name)
	check_exit_code $? "Terraform output"
	
	log_info "Criando repository variable..."
	gh variable set AWS_BUCKET_TFSTATE_ID --repo "${GITHUB_REPOSITORY}" --body "$BUCKET_NAME"
	check_exit_code $? "Repository variable creation"
	
	echo "AWS_BUCKET_TFSTATE_ID=$BUCKET_NAME" >> $GITHUB_OUTPUT
	log_success "Backend setup completo! Bucket: $BUCKET_NAME"
fi

