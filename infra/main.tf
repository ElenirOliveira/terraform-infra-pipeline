#provider "aws" {
 # region = "us-east-1"
#}

#resource "aws_s3_bucket" "data_lake" {
  #bucket = "data-lake-terraform"
  #}
  
provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "data_lake" {
  bucket = var.bucket_name

  tags = {
    Name        = "data-lake"
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}

resource "aws_iam_role" "glue_role" {
  name = "glue-service-role-data-lake"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "glue.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "glue_policy" {
  role       = aws_iam_role.glue_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_glue_job" "dim_account_job" {

  name     = "dim-account-job"
  role_arn = aws_iam_role.glue_role.arn

  command {
    script_location = "s3://data-lake-earaujoo-2026-pipeline/scripts/glue_job.py"
    python_version  = "3"
  }

  glue_version = "4.0"

  number_of_workers = 2
  worker_type       = "G.1X"

  execution_property {
    max_concurrent_runs = 1
  }
}


resource "aws_iam_policy" "glue_s3_policy" {

  name = "glue-s3-access-policy"

  policy = jsonencode({

    Version = "2012-10-17"

    Statement = [

      {
        Effect = "Allow"

        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]

        Resource = [
          "arn:aws:s3:::${var.bucket_name}",
          "arn:aws:s3:::${var.bucket_name}/*"
        ]
      }

    ]

  })
}

resource "aws_iam_role_policy_attachment" "glue_policy_attach" {

  role       = aws_iam_role.glue_role.name
  policy_arn = aws_iam_policy.glue_s3_policy.arn

}

resource "aws_iam_role_policy_attachment" "glue_service_role" {

  role       = aws_iam_role.glue_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"

}



