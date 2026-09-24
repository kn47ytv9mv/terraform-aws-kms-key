mock_provider "aws" {
}

run "invalid_key_usage_is_rejected" {
  command = plan

  variables {
    key_usage = "ENCRYPT_ONLY"
  }

  expect_failures = [var.key_usage]
}

run "deletion_window_outside_the_allowed_range_is_rejected" {
  command = plan

  variables {
    deletion_window_in_days = 3
  }

  expect_failures = [var.deletion_window_in_days]
}

run "key_rotation_enabled_by_default" {
  command = plan

  assert {
    condition     = aws_kms_key.resource.enable_key_rotation == true
    error_message = "enable_key_rotation should default to true."
  }
}

run "key_rotation_can_be_disabled" {
  command = plan

  variables {
    enable_key_rotation = false
  }

  assert {
    condition     = aws_kms_key.resource.enable_key_rotation == false
    error_message = "enable_key_rotation should pass through unchanged."
  }
}

run "policy_passes_through" {
  command = plan

  variables {
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [{
        Sid       = "EnableRootAccount"
        Effect    = "Allow"
        Principal = { AWS = "arn:aws:iam::123456789012:root" }
        Action    = "kms:*"
        Resource  = "*"
      }]
    })
  }

  assert {
    condition     = jsondecode(aws_kms_key.resource.policy).Statement[0].Sid == "EnableRootAccount"
    error_message = "policy should pass through unchanged."
  }
}

run "tags_pass_through" {
  command = plan

  variables {
    tags = {
      Name = "example-key"
    }
  }

  assert {
    condition     = aws_kms_key.resource.tags.Name == "example-key"
    error_message = "tags should pass through unchanged."
  }
}

run "single_region_by_default" {
  command = plan

  assert {
    condition     = aws_kms_key.resource.multi_region == false
    error_message = "A key should be single-region by default, since multi_region cannot be changed after creation and carries a higher cost."
  }
}

run "multi_region_passes_through" {
  command = plan

  variables {
    multi_region = true
    description  = "Cross-region data key"
  }

  assert {
    condition     = aws_kms_key.resource.multi_region == true
    error_message = "multi_region should pass through, since a single-region key cannot encrypt a cross-region replica."
  }

  assert {
    condition     = aws_kms_key.resource.description == "Cross-region data key"
    error_message = "The description should pass through unchanged."
  }
}

run "readme_default_example" {
  command = plan
}

run "readme_explicit_policy_example" {
  command = plan

  variables {
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Sid       = "EnableRootAccount"
          Effect    = "Allow"
          Principal = { AWS = "arn:aws:iam::123456789012:root" }
          Action    = "kms:*"
          Resource  = "*"
        },
        {
          Sid       = "AllowKeyUseByRole"
          Effect    = "Allow"
          Principal = { AWS = "arn:aws:iam::123456789012:role/example" }
          Action    = ["kms:Decrypt", "kms:GenerateDataKey"]
          Resource  = "*"
        }
      ]
    })
  }
}
