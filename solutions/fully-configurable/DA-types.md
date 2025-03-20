# Configuring complex inputs for Cloud Automation for VPC Private Path

Several optional input variables in the IBM Cloud [VPC Private path deployable architecture](https://cloud.ibm.com/catalog#deployable_architecture) use complex object types. You specify these inputs when you configure deployable architecture.

* Private Path Account policies (`private_path_account_policies`)

## Private Path Account policies <a name="private_path_account_policies"></a>

The `private_path_account_policies` input variable allows you to provide a list of AccountIDs from which requests to the private path is expected. For each AccountID, you need to specify if you need to `review`, `permit` or `deny` the requests from those AccountIDs.

- Variable name: `private_path_account_policies`.
- Type: A list of objects. Each object represents an Account ID.
- Default value: An empty list (`[]`).

### Options for private_path_account_policies

  - `account` (required): The Account ID.
  - `access_policy` (required): The access policy for each account ID. Allowed values are: review, Permit, Deny. review - All requests from the specific account ID are automatically flagged for review. Permit - All requests from the specific account ID are automatically accepted. Deny - All requests from the specific account ID are automatically rejected.

### Example Private Path Account policies Configuration

```hcl
[
  {
    account        = "gtf640basntrds7fc2b1p6thah78g36h"
    access_policy  = "review"
  },
  {
    account        = "nh9tnwed4ui6sqe5w8n4bjs97c22507g"
    access_policy  = "permit"
  }
]
```
