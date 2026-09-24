variable "description" {
  default     = null
  description = "Description of the key. Worth setting — a key is identified in the console and in most audit output by its ID, and an undescribed key is indistinguishable from every other."
}

variable "enable_key_rotation" {
  default     = true
  description = "Whether automatic key rotation is enabled. Only applies to symmetric encryption keys; AWS rejects it on an asymmetric or HMAC key."
}

variable "rotation_period_in_days" {
  default     = null
  description = "Days between automatic rotations, 90 to 2560. Only used when enable_key_rotation is true. If null, AWS's own default of 365 applies."
}

variable "is_enabled" {
  default     = null
  description = "Whether the key is enabled. A disabled key stays in place and keeps its policy and aliases, but no data can be encrypted or decrypted with it — the way to take a key out of service without the seven-day minimum wait that deletion imposes. If null, AWS's own default (enabled) applies."
}

variable "key_usage" {
  default     = null
  description = "What the key may do: 'ENCRYPT_DECRYPT' (the default and the only option for symmetric keys), 'SIGN_VERIFY' for asymmetric signing, or 'GENERATE_VERIFY_MAC' for HMAC. Cannot be changed after creation."

  validation {
    condition     = var.key_usage == null || contains(["ENCRYPT_DECRYPT", "SIGN_VERIFY", "GENERATE_VERIFY_MAC"], var.key_usage)
    error_message = "key_usage must be one of 'ENCRYPT_DECRYPT', 'SIGN_VERIFY', or 'GENERATE_VERIFY_MAC'."
  }
}

variable "customer_master_key_spec" {
  default     = null
  description = "The kind of key material: 'SYMMETRIC_DEFAULT' (the default), an RSA or ECC spec for asymmetric use ('RSA_4096', 'ECC_NIST_P256', and so on), or 'HMAC_256'. Must agree with key_usage — a signing key cannot be symmetric. Cannot be changed after creation."
}

variable "multi_region" {
  default     = false
  description = "Whether this is a multi-region key, which can be replicated into other regions so the same ciphertext decrypts in each. Required for anything spanning regions — a DynamoDB global table replica, a cross-region backup copy, or a cross-region read replica — because a single-region key cannot be used outside the region that holds it. Cannot be changed after creation, so a key that might ever be replicated must be created this way."
}

variable "deletion_window_in_days" {
  default     = null
  description = "Days AWS waits before destroying the key after deletion is scheduled, 7 to 30. The waiting period is the only chance to cancel — once it elapses, every ciphertext encrypted under the key is permanently unreadable. If null, AWS's own default of 30 applies."

  validation {
    condition     = var.deletion_window_in_days == null || (var.deletion_window_in_days >= 7 && var.deletion_window_in_days <= 30)
    error_message = "deletion_window_in_days must be between 7 and 30."
  }
}

variable "policy" {
  default     = null
  description = "IAM policy document (JSON) for the KMS key. If null, AWS's own default key policy applies (full access for the account root). A topic receiving CloudWatch alarms needs a policy granting cloudwatch.amazonaws.com kms:Decrypt and kms:GenerateDataKey* — see terraform-aws-sns-topic."
}

variable "tags" {
  default     = null
  description = "A map of tags to assign to the KMS key."
}
