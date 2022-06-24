.PHONY: lint tfscan generate-docs

lint:
	docker run --rm -v $${PWD}:/data -t ghcr.io/terraform-linters/tflint --var-file=/data/examples/test.tfvars

tfsec:
	docker run --rm -it -v "$$(pwd):/src" aquasec/tfsec /src --tfvars-file=/src/examples/test.tfvars

generate-docs:
	terraform-docs markdown table --config .terraform-docs.yml --output-file README.md --output-mode inject .
