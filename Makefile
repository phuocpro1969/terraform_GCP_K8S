init:
	terraform init
apply:
	terraform apply -auto-approve

plan:
	terraform plan

destroy:
	terraform destroy -auto-approve

output:
	terraform output

restart: destroy apply