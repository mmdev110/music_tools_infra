/*
CICDの流れ
github webhookに必要なトークンを生成してcodepipelineに渡しておく
codepipelineで
    githubからソースコード取得(Source)
    codebuild起動。ビルドとプッシュ(Build)
        codebuildはソースコード内のbuildspec.ymlに従ってビルド、ECRにプッシュ
    ECSにイメージをデプロイ(Deploy)

*/
module "codepipeline_role" {
  source     = "./iam_role"
  name       = "codepipeline"
  identifier = "codepipeline.amazonaws.com"
  policy     = data.aws_iam_policy_document.codepipeline.json
}
//アーティファクト保管用のS3
resource "aws_s3_bucket" "artifact" {
  bucket = "loopthatloop-artifacts-prod"
}
data "aws_iam_policy_document" "codepipeline" {
  statement {
    effect    = "Allow"
    resources = ["*"]
    //ステージ間でアーティファクトをやりとりするためのS3
    //codebuildの起動
    //ECSへのデプロイ
    //codebuild, ECSへロールを渡すためのpassrole
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketVersioning",
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild",
      "ecs:DescribeServices",
      "ecs:DescribeTaskDefinition",
      "ecs:DescribeTasks",
      "ecs:ListTasks",
      "ecs:RegisterTaskDefinition",
      "ecs:UpdateService",
      "iam:PassRole",
    ]
  }
}
resource "aws_codepipeline" "example" {
  name     = "example"
  role_arn = module.codepipeline_role.iam_role_arn
  //artifactの保管場所
  artifact_store {
    location = aws_s3_bucket.artifact.id
    type     = "S3"
  }
  stage {
    name = "Source"
    action {
      name     = "Source"
      category = "Source"
      //githubから取得
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = 1
      output_artifacts = ["Source"]
      configuration = {
        Owner  = "my-github-name"
        Repo   = "my-repo"
        Branch = "main"
        //webhookから起動するためcodepipeline自体からはポーリングしない
        PollForSourceChanges = false
      }
    }
  }
  stage {
    name = "Build"
    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = 1
      input_artifacts  = ["Source"]
      output_artifacts = ["Build"]
      configuration = {
        ProjectName = aws_codebuild_project.example.id
      }
    }
  }
  stage {
    name = "Deploy"
    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      version         = 1
      input_artifacts = ["Build"]
      configuration = {
        ClusterName = aws_ecs_cluster.example.name
        ServiceName = aws_ecs_service.example.name
        FileName    = "imagedefinitions.json" //buildspec.ymlで出力しているもの
      }
    }
  }
}
//webhook
resource "aws_codepipeline_webhook" "example" {
  name            = "example"
  target_pipeline = aws_codepipeline.example.name
  target_action   = "Source" //最初に実行するアクション
  authentication  = "GITHUB_HMAC"
  authentication_configuration {
    secret_token = "GENERATED TOKEN"
  }
  filter { //起動条件
    json_path = "$.ref"
    //aws_codepipelineで指定したブランチでの実行
    match_equals = "refs/heads/{Branch}"
  }
}
provider "github" {
  owner = "your-github-name"
}
resource "github_repository_webhook" "example" {
  repository = "your-repository"
  configuration {
    url          = aws_codepipeline_webhook.example.url
    secret       = "GENERATED_TOKEN"
    content_type = "json"
    insecure_ssl = false
  }
  events = ["push"]
}