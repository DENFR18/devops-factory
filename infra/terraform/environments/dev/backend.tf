terraform {
  backend "s3" {
    bucket                      = "devops-factory-tfstate-dev"
    key                         = "terraform.tfstate"
    region                      = "fr-par"
    endpoint                    = "https://s3.fr-par.scw.cloud"
    skip_credentials_validation = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    # Set AWS_ACCESS_KEY_ID=<SCW_ACCESS_KEY> and AWS_SECRET_ACCESS_KEY=<SCW_SECRET_KEY>
    # before running terraform init (the S3 backend uses AWS SDK env vars).
  }
}
