export GOOGLE_IDP_ID?=C01501d06
export GOOGLE_SP_ID?=192607830114
export AZURE_TENANT_ID?=PLACEHOLDER
export AZURE_APP_ID_URI?=PLACEHOLDER
AWS_ACCOUNT_ID_MASTER=703659973405

GOOGLE_AUTH_IMAGE=dnxsolutions/aws-google-auth:latest
AZURE_AUTH_IMAGE=dnxsolutions/docker-aws-azure-ad:1.0.0
AWS_IMAGE=dnxsolutions/aws:1.18.44-dnx2
TERRAFORM_IMAGE=dnxsolutions/terraform:0.13.0-dnx1

RUN_GOOGLE_AUTH=docker run -it --rm --env-file=.env -v $(PWD)/.env.auth:/work/.env $(GOOGLE_AUTH_IMAGE)
RUN_AZURE_AUTH =docker run -it --rm --env-file=.env -v $(PWD)/.env.auth:/work/.env $(AZURE_AUTH_IMAGE)
RUN_AWS        =docker run -it --rm --env-file=.env.auth --env-file=.env -v $(PWD):/work --entrypoint "" $(AWS_IMAGE)
RUN_TERRAFORM  =docker run -i --rm --env-file=.env.auth --env-file=.env -v $(PWD):/work $(TERRAFORM_IMAGE)

env-%: # Check for specific environment variables
	@ if [ "${${*}}" = "" ]; then echo "Environment variable $* not set"; exit 1;fi

.env:
	cp .env.template .env
	echo >> .env
	touch .env.auth

clean-dotenv:
	-rm .env

dnx-assume: clean-dotenv .env
	AWS_ACCOUNT_ID=$(AWS_ACCOUNT_ID_MASTER) \
	AWS_ROLE=DNXAccess \
		$(RUN_AWS) assume-role.sh >> .env

google-auth: .env env-GOOGLE_IDP_ID env-GOOGLE_SP_ID
	echo > .env.auth
	$(RUN_GOOGLE_AUTH)

azure-auth: .env env-AZURE_TENANT_ID env-AZURE_APP_ID_URI
	echo > .env.auth
	$(RUN_AZURE_AUTH)

init: .env env-WORKSPACE
	$(RUN_TERRAFORM) init
	$(RUN_TERRAFORM) workspace new $(WORKSPACE) 2>/dev/null; true # ignore if workspace already exists
	$(RUN_TERRAFORM) workspace "select" $(WORKSPACE)
.PHONY: init

shell: .env
	docker run -it --rm --env-file=.env.auth --env-file=.env -v $(PWD):/work --entrypoint "/bin/bash" $(TERRAFORM_IMAGE)
.PHONY: shell

apply: .env env-WORKSPACE
	$(RUN_TERRAFORM) apply .terraform-plan-$(WORKSPACE)
.PHONY: apply
 
plan: .env env-WORKSPACE
	$(RUN_TERRAFORM) plan -out=.terraform-plan-$(WORKSPACE)
.PHONY: plan

################################################
#Make for CI/CD (the ci template is different from the manual process)
.env_ci:
	cp ./.env.ci.template/.env.template .env
	echo >> .env
	touch .env.auth

init_ci: .env_ci env-WORKSPACE
	$(RUN_TERRAFORM) init
	$(RUN_TERRAFORM) workspace new $(WORKSPACE) 2>/dev/null; true # ignore if workspace already exists
	$(RUN_TERRAFORM) workspace "select" $(WORKSPACE)
.PHONY: init

shell_ci: .env_ci
	docker run -it --rm --env-file=.env.auth --env-file=.env -v $(PWD):/work --entrypoint "/bin/bash" $(TERRAFORM_IMAGE)
.PHONY: shell

apply_ci: .env_ci env-WORKSPACE
	$(RUN_TERRAFORM) apply .terraform-plan-$(WORKSPACE)
.PHONY: apply

plan_ci: .env_ci env-WORKSPACE
	$(RUN_TERRAFORM) plan -out=.terraform-plan-$(WORKSPACE)
.PHONY: plan
