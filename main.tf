locals {
  secret_name = "${var.environment}/kart-ai-db-creds"
  google_secret_values = jsondecode(data.aws_secretsmanager_secret_version.google_creds.secret_string)
}

# Retrieve Google OAuth credentials from AWS Secrets Manager
data "aws_secretsmanager_secret" "google_creds" {
  name = local.secret_name
}

data "aws_secretsmanager_secret_version" "google_creds" {
  secret_id = data.aws_secretsmanager_secret.google_creds.id
}

# Cognito User Pool
resource "aws_cognito_user_pool" "main" {
  name = "kart-ai-user-pool"

  auto_verified_attributes = ["email"]

  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_uppercase = true
    require_numbers   = true
    require_symbols   = false
  }

  admin_create_user_config {
    allow_admin_create_user_only = false
  }

  schema {
    attribute_data_type      = "String"
    name                     = "email"
    required                 = true
    developer_only_attribute = false
    mutable                  = true
  }
}

# Cognito User Pool Client
resource "aws_cognito_user_pool_client" "api_client" {
  name         = "my-api-client"
  user_pool_id = aws_cognito_user_pool.main.id
  generate_secret = false

  allowed_oauth_flows                 = ["code", "implicit"]
  allowed_oauth_scopes                = ["email", "openid", "profile"]
  callback_urls                       = ["https://example.com/callback"]
  logout_urls                         = ["https://example.com/logout"]
  supported_identity_providers        = ["COGNITO", "Google", "Facebook"]
  allowed_oauth_flows_user_pool_client = true
}


# 3. Cognito Identity Provider - Google
resource "aws_cognito_identity_provider" "google" {
  user_pool_id  = aws_cognito_user_pool.main.id
  provider_name = "Google"
  provider_type = "Google"

  provider_details = {
    client_id         = local.google_secret_values.oidc_google_client_id
    client_secret     = local.google_secret_values.oidc_google_secret
    authorize_scopes  = "profile email openid"
  }

  attribute_mapping = {
    email = "email"
    name  = "name"
  }
}

# # 4. Cognito Identity Provider - Facebook
# resource "aws_cognito_identity_provider" "facebook" {
#   user_pool_id  = aws_cognito_user_pool.main.id
#   provider_name = "Facebook"
#   provider_type = "Facebook"

#   provider_details = {
#     client_id     = "FACEBOOK_APP_ID"
#     client_secret = "FACEBOOK_APP_SECRET"
#     authorize_scopes = "email public_profile"
#   }

#   attribute_mapping = {
#     email = "email"
#     name  = "name"
#   }
# }

