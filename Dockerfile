# Use alpine as the base image
FROM ubuntu:latest

# Install bash, curl, jq, and other dependencies
RUN apt update && \
    apt install  bash curl jq zip  -y

# Install Terraform
ARG TERRAFORM_VERSION=1.9.3
RUN curl -LO https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    mv terraform /usr/local/bin/ && \
    rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip
