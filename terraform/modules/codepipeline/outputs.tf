output "codepipeline_arn" {
  value = aws_codepipeline.this.arn
}

output "codepipeline_id" {
  value = aws_codepipeline.this.id
}

output "codebuild_project_arn" {
  value = aws_codebuild_project.this.arn
}

output "codebuild_project_id" {
  value = aws_codebuild_project.this.id
}
