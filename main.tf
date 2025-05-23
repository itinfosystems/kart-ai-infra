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
  name            = "kart-ai-api-client"
  user_pool_id    = aws_cognito_user_pool.main.id
  generate_secret = false

  allowed_oauth_flows                 = ["code", "implicit"]
  allowed_oauth_scopes                = [
                                          "email", 
                                          "openid", 
                                          "profile", 
                                          "${aws_cognito_resource_server.resource.identifier}/read", 
                                          "${aws_cognito_resource_server.resource.identifier}/write"]
  callback_urls                       = ["http://localhost:8000/docs/oauth2-redirect"]
  logout_urls                         = ["https://example.com/logout"]
  supported_identity_providers        = [
    "COGNITO", 
    "Google"]
  allowed_oauth_flows_user_pool_client = true
}

# Create a resource server for custom scopes
resource "aws_cognito_resource_server" "resource" {
  identifier = "kart-ai"
  name       = "KartAI API"
  
  scope {
    scope_name        = "read"
    scope_description = "Read access to KartAI API"
  }
  
  scope {
    scope_name        = "write"
    scope_description = "Write access to KartAI API"
  }
  
  user_pool_id = aws_cognito_user_pool.main.id
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

  lifecycle {
    ignore_changes = [
      provider_details,
      attribute_mapping
    ]
  }
}

# Cognito User Pool Domain
resource "aws_cognito_user_pool_domain" "main" {
  domain       = "kart-ai-${var.environment}"
  user_pool_id = aws_cognito_user_pool.main.id
}

# Create a test user if enabled
resource "aws_cognito_user" "test_user" {
  count = var.create_test_user ? 1 : 0

  user_pool_id = aws_cognito_user_pool.main.id
  username     = "baker"
  
  password = "Letmein!1"
  
  attributes = {
    email          = "test@example.com"
    email_verified = true
  }
  
  message_action = "SUPPRESS" # Suppress welcome email
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

