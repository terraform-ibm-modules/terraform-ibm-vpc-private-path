# Configuring complex inputs for Cloud Automation for VPC Private Path

Several optional input variables in the IBM Cloud [VPC Private path deployable architecture](https://cloud.ibm.com/catalog#deployable_architecture) use complex object types. You specify these inputs when you configure deployable architecture.

- [Private Path Account policies](#options-with-acc-policies) (`private_path_account_policies`)
- [Network Loadbalancer Backend Pools](#options-with-backend-pools) (`network_loadbalancer_backend_pools`)

## Private Path Account policies <a name="options-with-acc-policies"></a>

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

## Options with Network Loadbalancer Backend Pools <a name="options-with-backend-pools"></a>

The `network_loadbalancer_backend_pools` input variable allows you to provide of a list describing the backend pools for the private path network load balancer.

- Variable name: `network_loadbalancer_backend_pools`.
- Type: A list of objects.
  - `pool_name` (required): The name of the backend pool. This should be unique across the list.
  - `pool_algorithm` (optional): The load-balancing algorithm. Supported values are `round_robin`, `weighted_round_robin`.
  - `pool_health_delay` (optional): (number) The health check interval in seconds. Interval must be greater than timeout value.
  - `pool_health_retries` (optional): (number) The health check max retries.
  - `pool_health_timeout` (optional): (number) The health check timeout in seconds.
  - `pool_health_type` (optional): The pool protocol. Enumeration type: `http`, `tcp` are supported.
  - `pool_health_monitor_url` (optional): This URL is used to send health check requests to the instances in the pool. By default, this is the root path `/`.
  - `pool_health_monitor_port` (optional): (number) The port on which the load balancer sends health check requests. By default, health checks are sent on the same port where traffic is sent to the instance.
  - `pool_member_port` (optional): The port number of the application running in the server member.
  - `pool_member_instance_ids` (optional): (List) List of virtual server instances which will attached as members to the backend pool.
  - `pool_member_application_load_balancer_id` (optional): ID of the Application loadbalancer to attach as a member of the backend pool. You can have only 1 Application loadbalancer in a backend pool.
  - `listener_accept_proxy_protocol` (optional): (bool) If set to true, listener forwards proxy protocol information that are supported by load balancers in the application family. Default value is false.
  - `listener_port` (optional): (number) The listener port number. Valid range 1 to 65535.
- Default value: An empty list ([]).


### Example Rule For Network Loadbalancer Backend Pools Configuration

```hcl
[
  {
    pool_name                = "backend-1"
    pool_member_instance_ids = ["xbxm1pimp8zn5e7gxm38q8hgur5ecok1", "f0v9aiyc3l0t2s2xjknnw22vmcdi5sy6", "vlrliqfig4mb3egzya15lq51ln77f8l9"]
    pool_member_port         = 80
    pool_health_delay        = 60
    pool_health_retries      = 5
    pool_health_timeout      = 30
    pool_health_type         = "tcp"
    listener_port            = 80
  },
  {
    pool_name                                = "backend-2"
    pool_member_application_load_balancer_id = "obxyvrvjithe365z6l8nhxeieksb2ejn"
    pool_member_port                         = 80
    pool_health_delay                        = 60
    pool_health_retries                      = 5
    pool_health_timeout                      = 30
    pool_health_type                         = "http"
    listener_port                            = 81
  }
]
```
