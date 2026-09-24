# terraform-aws-kms-key

Terraform module for a customer managed KMS key with automatic key rotation
enabled out of the box.

## Cost

KMS bills a flat monthly fee per customer managed key, plus per-request
charges above a monthly free tier — this module creates the key itself,
so both charges originate here. See AWS's
[KMS pricing](https://aws.amazon.com/kms/pricing/) page for current
rates.

## Design

Leaving `policy` null does not mean no policy applies — AWS falls back
to its own default key policy, granting the account root full `kms:*`
access. Pass an explicit `policy` to scope permissions further (specific
IAM roles or users, cross-account access, and so on).

This module creates only the key itself, not an alias. Pair with your
own `aws_kms_alias` resource for a human-readable name (`alias/my-key`)
— a bare key ID or ARN is the only handle this module exposes.

## Usage

```hcl
module "key" {
  source = "kn47ytv9mv/kms-key/aws"
}
```

Or directly from this repository, with an explicit policy scoping access
to one IAM role:

```hcl
module "key" {
  source = "github.com/kn47ytv9mv/terraform-aws-kms-key"

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
        Principal = { AWS = aws_iam_role.example.arn }
        Action    = ["kms:Decrypt", "kms:GenerateDataKey"]
        Resource  = "*"
      }
    ]
  })
}
```

## Requirements

| Name | Version |
|---|---|
| terraform | >= 1.2 |
| aws | ~> 6.61 |

## Providers

| Name | Version |
|---|---|
| aws | ~> 6.61 |

## Inputs

| Name | Description | Default | Required |
|---|---|---|---|
| description | Description of the key. Worth setting — an undescribed key is indistinguishable from every other in the console and in audit output. | `null` | no |
| enable_key_rotation | Whether automatic key rotation is enabled. Symmetric encryption keys only; AWS rejects it on an asymmetric or HMAC key. | `true` | no |
| rotation_period_in_days | Days between automatic rotations, 90 to 2560. If null, AWS's own default of 365 applies. | `null` | no |
| is_enabled | Whether the key is enabled. A disabled key keeps its policy and aliases but cannot encrypt or decrypt — the way to take a key out of service without deletion's minimum seven-day wait. | `null` | no |
| key_usage | `'ENCRYPT_DECRYPT'`, `'SIGN_VERIFY'`, or `'GENERATE_VERIFY_MAC'`. Cannot be changed after creation. | `null` | no |
| customer_master_key_spec | Key material: `'SYMMETRIC_DEFAULT'`, an RSA or ECC spec, or `'HMAC_256'`. Must agree with `key_usage`. Cannot be changed after creation. | `null` | no |
| multi_region | Whether this is a multi-region key, replicable into other regions. Required for a DynamoDB global table replica, a cross-region backup copy, or a cross-region read replica. Cannot be changed after creation. | `false` | no |
| deletion_window_in_days | Days AWS waits before destroying the key after deletion is scheduled, 7 to 30. The only chance to cancel. | `null` | no |
| policy | IAM policy document (JSON) for the KMS key. If null, AWS's own default key policy applies (full access for the account root). | `null` | no |
| tags | A map of tags to assign to the KMS key. | `null` | no |

## Outputs

| Name | Description |
|---|---|
| id | The key's ID, the short identifier distinct from its ARN. Either form works as `terraform-aws-kms-alias`'s `target_key_id`. |
| arn | The ARN of the KMS key. |
| region | The region of the KMS key. |

## License

MIT — see [LICENSE.md](LICENSE.md).
