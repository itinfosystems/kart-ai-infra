output "cognito_domain" {
  description = "The Cognito domain name"
  value       = aws_cognito_user_pool_domain.main.domain
}