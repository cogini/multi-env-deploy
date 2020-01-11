output "repository_name" {
  description = "Repository name"
  value       = aws_codecommit_repository.this.repository_name
}

output "default_branch" {
  description = "Repository default branch name"
  value       = aws_codecommit_repository.this.default_branch
}

output "repository_id" {
  description = "Repository ID"
  value       = aws_codecommit_repository.this.repository_id
}

output "arn" {
  description = "Repository ARN"
  value       = aws_codecommit_repository.this.arn
}

output "clone_url_http" {
  description = "URL to use for cloning the repository over HTTPS"
  value       = aws_codecommit_repository.this.clone_url_http
}

output "clone_url_ssh" {
  description = "URL to use for cloning the repository over SSH"
  value       = aws_codecommit_repository.this.clone_url_ssh
}

