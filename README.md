<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->

<a href="https://terraform.io">
    <img src="https://upload.wikimedia.org/wikipedia/commons/0/04/Terraform_Logo.svg" alt="Terraform logo" title="Terraform" height="30" />
</a>
&nbsp;
<a href="https://opennebula.io/">
    <img src="https://opennebula.io/wp-content/uploads/2013/12/opennebula_cloud_logo_white_bg.png" alt="OpenNebula logo" title="OpenNebula" height="30" />
</a>

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->


# Please be extremely careful when making changes.

***After creating a merge request, be sure to check the output of all three stages:***

  The `validate` stage contains a script that checks the disk size of virtual machines to ensure it's not less than the current size. If the size is smaller, the stage will fail.

  The `check` stage displays the output of the `terraform plan` command, allowing you to review the overall changes. If any line of code is missing, for example, the CPU definition for a virtual machine, it will fail.  

  The `validation-destroy` stage is for checking resource deletions:

- If no resource has been deleted, it will `succeed`.  

- If a resource has been deleted, it will generate a `warning`.

***After performing the merge request, you can go to the pipeline. In this section, you will encounter the `DELETIONS` variable, which is set to `false` by default:***

- The `false` value prevents the `create` stage from running.  
  
- The `true` value indicates that the executor has confirmed and verified that all deletions were correct and intends to execute the process, at which point the `create` stage will run, and the `terraform apply` command will be executed.

***Changes in module code or adding a new module***

If you make any changes to the code, be sure to test them in the test environment. From experience, your code may work correctly after running `terraform apply` and the desired changes may be applied successfully. However, if you run `terraform apply` again, you might see additional changes. Therefore, after modifying the module code or adding a module, run the `terraform apply` command several times to ensure that the output is stable and that the changes persist.

# Terraform OpenNebula Configuration

This repository contains Terraform configurations for managing OpenNebula resources.




## Prerequisites

There are two plugins for Terraform:

1. The plugin **terraform-provider-opennebula_1.4.0_linux_amd64**, Given that the last source code update was three years ago and there have been no updates since, the following changes have been made:

   - In the source code `resource_opennebula_user.go`: The issue with user authentication using the LDAP service has been resolved. The problem was with setting the user's password.
   - In the source code `resource_opennebula_template.go`: Options for "Enable hot resize", "Max memory", "Memory Resize Mode", and "Max VCPU" have been added.
   - In the source code `resource_opennebula_virtual_machine.go`: To resize the RAM/CPU of a virtual machine, Terraform previously required the virtual machine to be shut down. With the necessary changes, the virtual machine no longer shuts down and resizing is performed using HotPlug.

2. The plugin **terraform-provider-vault_v4.3.0_x5**, This plugin has been obtained from the website registry.terraform.io, but due to security concerns and lack of direct internet access for downloading plugins, this plugin is used locally to avoid proxy issues.

Both plugins are located at the following path and are downloaded using `provider_installation`. To download the plugins, transfer the `.terraformrc` file to your `home directory` and then run `terraform init`.

<https://repo.snapp.tech/repository/raw/registry.terraform.io/snapp/opennebula>

## Initial Setup

All production work should be carried out by CI to ensure that all tasks are logged and trackable. However, for local testing, you can comment out the backend configuration in the provider.tf file. This will prevent the use of Remote_State_File for code testing and development, making the terraform.tfstate file local.

### Please be very careful: code changes without prior testing and verification can have serious consequences

Clone the repository:

```bash
    git clone https://gitlab.com/your-repo/terraform-opennebula.git
    cd terraform-opennebula
    cp .terraformrc  ~/
    terraform init
```

# Terraform OpenNebula Configuration: `Groups Resource`

The configurations for the template resource are located in the groups.tfvars file.

The `opennebula_group` resource creates groups in OpenNebula based on the provided variables. Each group is configured with a distinguished name (DN) required for LDAP server integration.

#### Variables

- **groups**: A map containing the group names and their corresponding DN values. This map is defined in the `groups.tfvars` file.

#### Example Configuration

In the `groups.tfvars` file, you can define the group names and their corresponding DNs as follows:

```hcl
groups = {
  "onedba" = {
    group_dn = "cn=onedba,cn=groups,cn=accounts,dc=company,dc=ecs"
  }
...  
}
```

Each entry in the `groups` map represents a group to be created in OpenNebula.

### Configuration Details

The key is the group `name`, and the value is a map containing the `group_dn`, which specifies the distinguished name of the group in the LDAP server.

### Note

Ensure that the specified groups already exist on the LDAP server before running the Terraform configuration. The Terraform configuration will not create groups on the LDAP server; it only references them.

### Steps to Update Groups Resource

**Modify the Resource Configuration**
Update the resource definition in modules/resources/main.tf if needed.

**Update the Variables Definition**
Adjust the variable definitions in the variables.tf file if new variables are introduced or existing ones are modified.

**Set the Variable Values**
Specify the group names and their DNs in the groups.tfvars file as shown in the example above.
By following these steps, you can manage the group resources in OpenNebula efficiently using Terraform.

## Terraform OpenNebula Configuration: `ACLs Resource`

The configurations for the template resource are located in the acls.tfvars file.

The `opennebula_acl` resource manages ACL (Access Control List) rules in OpenNebula. Each ACL rule is defined based on the user, resource type, and associated rights.

#### Variables

- **acls**: This variable is a map where each key represents an ACL rule name, and the associated value contains the details for that ACL rule.

#### Example Configuration

In the `acls.tfvars` file, you define the ACL rules as follows:

```hcl
acls = {
  "acl_for_oneadmin" = {
    user     = "onereadonly"
    resource = "VM+HOST+NET+IMAGE+USER+TEMPLATE+GROUP+DATASTORE+CLUSTER+DOCUMENT+ZONE+SECGROUP+VDC+VROUTER+MARKETPLACE+MARKETPLACEAPP+VMGROUP/*"
    rights   = "USE"
  },
  "acl_for_onesecurityteam" = {
    user     = "onesecurityteam"
    resource = "HOST+VM+NET+IMAGE+DOCUMENT+VROUTER/*"
    rights   = "USE"
  },
  "acl_for_onedatateam" = {
    user     = "onedatateam"
    resource = "VM+IMAGE+TEMPLATE+DOCUMENT+SECGROUP+VROUTER/*"
    rights   = "USE"
  }
}
```

Each entry in the `acls` map represents an ACL rule to be created in OpenNebula. The user specifies the user or group the ACL applies to, the resource defines the type of resources the rule affects, and the rights determine the permissions granted.

### Configuration Details

### Note

Group Name Consistency:

**The user argument** should be specified as @<group_name>. The @ symbol indicates that the user is a group and not an individual user. Make sure that the group name provided in the user field corresponds to a group defined in the groups.tfvars file.

**resource** should contain a slash to denote the resource subset. Valid resource types include:

- VM
- HOST
- NET
- IMAGE
- USER
- TEMPLATE
- GROUP
- DATASTORE
- CLUSTER
- DOCUMENT
- ZONE
- SECGROUP
- VDC
- VROUTER
- MARKETPLACE
- MARKETPLACEAPP
- VMGROUP
- VNTEMPLATE

**rights** defines the permissions for the ACL rule. Valid rights include:

- USE
- MANAGE
- ADMIN
- CREATE

### Configuration Steps

**Modify the Resource Definition**
Update the opennebula_acl resource configuration in the modules/resources/main.tf file if necessary.

**Update the Variables Definition**
Adjust the variable definitions in the variables.tf file if new variables are needed or existing ones are modified.

**Set the Variable Values**
Define the ACL rules in the acls.tfvars file as shown in the example above.

**Ensure Group Existence**
Ensure that the groups referenced in the acls.tfvars file already exist and are defined in the groups.tfvars file. Terraform will first create the groups and then apply the ACLs to them.
By following these guidelines, you can efficiently manage ACL rules in OpenNebula using Terraform.

# Terraform OpenNebula Configuration: `Users Resource`

The configurations for the template resource are located in the users.tfvars file.

### Resource Configuration

The `opennebula_user` resource creates users in OpenNebula based on the specified variables. Each user is authenticated via LDAP and assigned to primary and secondary groups.

#### Variables

- **users**: This variable is a list where each item represents a user, and contains details such as the user's name, primary group, and secondary groups.

#### Example Configuration

In the `users.tfvars` file, you define the users as follows:

```hcl
users = [
  {
    name          = "example.user"
    primary_group = "oneadmin"
    groups        = ["oneadmin"]
  }
]
```

Each entry in the `users` list represents a user to be created in OpenNebula. The name is the username, the primary_group specifies the primary group the user belongs to, and the groups list contains the secondary groups the user is part of.

### Configuration Details

**User Name**
The name argument specifies the username. This username must match the username in the LDAP server.

**Primary Group**
The primary_group argument specifies the primary group the user belongs to. This group must exist in the groups.tfvars file.

**Secondary Groups**
The groups argument specifies the secondary groups the user belongs to. This can include one or multiple groups, all of which must exist in the groups.tfvars file.

### Note

Group Existence:
Ensure that the groups referenced in the users.tfvars file already exist and are defined in the groups.tfvars file. Terraform will first create the groups and then assign users to these groups.
If both the group and user are being created simultaneously, Terraform will create the group first, retrieve its ID, and then assign the user to it. This ensures that OpenNebula correctly associates the user with the specified group.
Consistent Group Assignment:

Always ensure that the `primary_group` and `groups` values are correctly specified to grant the appropriate access to users. Properly managing these values ensures users have the right permissions and group associations.

### Configuration Steps

**Modify the Resource Definition**
Update the opennebula_user resource configuration in the modules/resources/main.tf file if necessary.

**Update the Variables Definition**
Adjust the variable definitions in the variables.tf file if new variables are needed or existing ones are modified.

**Set the Variable Values**
Define the users in the users.tfvars file as shown in the example above.
By following these guidelines, you can efficiently manage user resources in OpenNebula using Terraform.

# Terraform OpenNebula Configuration: `Networks Resource`

The configurations for the template resource are located in the networks.tfvars file.

### Resource Configuration

The `opennebula_virtual_network` resource creates virtual networks in OpenNebula based on the specified variables. Each network is configured with various attributes such as bridge interface, network type, and address ranges.

#### Variables

- **networks**: This variable is a map where each key-value pair represents a virtual network and its configuration details.

#### Example Configuration

In the `networks.tfvars` file, you define the networks as follows:

```hcl
networks = {
  vlan770 = {
    name            = "ecs-1G"
    bridge          = "br4"
    type            = "bridge"
    gateway         = "172.16.77.134"
    network_mask    = "255.255.252.0"
    network_address = "172.16.77.0"
    mtu             = null
    ar              = [
      { ar_type = "IP4", size = 200, ip4 = "172.16.77.50" },
      { ar_type = "IP4", size = 255, ip4 = "172.16.76.1" },
      { ar_type = "IP4", size = 255, ip4 = "172.16.78.1" }
    ]
    VN_MAD = "dummy"
  }
}
```

Each entry in the `networks` map represents a virtual network to be created in OpenNebula. The configuration details include the bridge interface, network type, gateway, network mask, and address ranges.

### Configuration Details

**Name**
The name argument specifies the name of the virtual network. This name can be chosen based on the VLAN name or any other naming convention.

**Bridge**
The bridge argument specifies the bridge interface name. This should match the bridge interface configured on the compute node's network. For example, br0 for a 1G network or br4 for a 10G network.

- br0
- br4

**Type**
The type argument specifies the type of the virtual network. It can be one of the following, The default is bridge, and it is the commonly used type in our configurations.

- dummy
- fw
- bridge
- ebtables
- 802.1Q
- vxlan
- ovswitch

**Gateway**
The gateway argument specifies the gateway for the virtual network. If you are defining a secondary network that does not have a gateway, set this argument to null.

**Network_Mask**
The network_mask argument specifies the network mask for the virtual network.

**Network_Address**
The network_address argument specifies the network address for the virtual network.

**MTU**
The mtu argument specifies the Maximum Transmission Unit size. For VLAN isolation used in databases, set this to 9000. Otherwise, set it to null.

**Address Ranges (AR)**
The ar argument is a list of address ranges. Each address range specifies the type (ar_type), size (size), and starting IP address (ip4).

**VN_MAD**
The VN_MAD argument is a tag used for the virtual network.

### Note

`Null Values`:
For any parameter that does not have a specific value in your configuration, set it to null. This ensures that the parameter is handled correctly without causing configuration errors.

### Configuration Steps

**Modify the Resource Definition**
Update the opennebula_virtual_network resource configuration in the modules/resources/main.tf file if necessary.

**Update the Variables Definition**
Adjust the variable definitions in the variables.tf file if new variables are needed or existing ones are modified.

**Set the Variable Values**
Define the networks in the networks.tfvars file as shown in the example above.
By following these guidelines, you can efficiently manage network resources in OpenNebula using Terraform.

# Terraform OpenNebula Configuration: Images Resource

The configurations for the template resource are located in the images.tfvars file.

### Resource Configuration

The `opennebula_image` resource creates images in OpenNebula based on the specified variables. Each image is configured with various attributes such as datastore ID, path, and device prefix.

#### Variables

- **images**: This variable is a list where each element represents an image and its configuration details.

#### Example Configuration

In the `images.tfvars` file, you define the images as follows:

```hcl
images = [
  {
    name         = "Rocky Linux 9"
    datastore_id = 1
    persistent   = false
    lock         = "MANAGE"
    path         = "https://marketplace.opennebula.io/appliance/9310bc80-7aea-013b-d6f1-7875a4a4f528"
    dev_prefix   = "vd"
    driver       = "qcow2"
    group        = "oneadmin"
  }
]
```

Each entry in the `images` list represents an image to be created in OpenNebula. The configuration details include the datastore ID, path, and device prefix.

### Configuration Details

**Image Name**
The name argument specifies the name of the image. This name can be chosen based on your naming convention.

**Datastore ID**
The datastore_id argument specifies the ID of the datastore used to store the image. It is a required argument and is usually set to 1.

**Lock**
The lock argument is optional and locks the image with a specific lock level. Supported values are:

- USE
- MANAGE
- ADMIN
- ALL
- UNLOCK

**Path**
The path argument is optional and specifies the path or URL of the original image to use. This conflicts with clone_from_image. You can find the path in the storage section under apps by selecting any desired image in the Attributes section, or you can use the OpenNebula marketplace:
*<https://marketplace.opennebula.io/appliance/>*

**Device Prefix**
The dev_prefix argument is optional and specifies the device prefix on the Virtual Machine. It is usually one of these and We always choose vd.

- hd
- sd
- vd

**Driver**
The driver argument is optional and specifies the OpenNebula driver to use. If using the MANAGE method, it should be set to qcow2.

**Group**
The group argument specifies the group associated with the image. It is usually set to oneadmin unless in special conditions.

### Configuration Steps

**Modify the Resource Definition**
Update the opennebula_image resource configuration in the modules/resources/main.tf file if necessary.

**Update the Variables Definition**
Adjust the variable definitions in the variables.tf file if new variables are needed or existing ones are modified.

**Set the Variable Values**
Define the images in the images.tfvars file as shown in the example above.
By following these guidelines, you can efficiently manage image resources in OpenNebula using Terraform.

# Terraform OpenNebula Configuration: `hosts Resource`

The configurations for hosts resources are located in the hosts.tfvars file.

### Resource Configuration

The `opennebula_host` source code is used to add a new host to OpenNebula.

#### Variables

- **host**: This variable is a map where each key-value pair represents a virtual network and its configuration details.

#### Example Configuration

In the `hosts.tfvars` file, you define the compute as follows:

```hcl
hosts = {
  "Nebula-master-01.ecs.infra" = {
    cluster_id = "0"
    labels     = "Nebula M,D-S-7T 80%"
    cpu        = 10800        # overcommit 88 Threads
    memory     = 262144000    # overcommit Adjusted memory size as needed        
  }
}
```

Specify the hostname and labels.

### Configuration Details

**TAGS**

For Labels, there are three tags:

- Tag **D-H-40T 80%**: The `D-H (Disk Huge)` tag refers to bare metal servers with disk capacities greater than `40 terabytes`.
- Tag **D-M-20T 80%**: The `D-M (Disk Medium)` tag refers to bare metal servers with disk capacities greater than `20 terabytes`.
- Tag **D-S-7T 80%**:  The `D-S (Disk Small)` tag refers to bare metal servers with disk capacities greater than `7 terabytes`.

The percentage `80%` means that the allocated RAM and CPU should not exceed 80%, leaving 20% for emergencies where virtual machines on this bare metal might need additional RAM/CPU.

# Terraform OpenNebula Configuration: `template Resource`

The configurations for the template resource are located in the templates.tfvars file.

### Resource Configuration

The `opennebula_template` source code is used to create a template.

#### Variables

- **template**: This variable is a map where each key-value pair represents a host and its configuration details.

#### Example Configuration

In the `templates.tfvars` file, you define the template as follows:

```hcl
templates = {
  "Afra-Ubuntu24.04" = {
    image_id           = "Ubuntu 24.04"
    network_ids        = ["ecs-10G", "ecs-DB"]
    sched_requirements = "CLUSTER_ID=\"0\""
    start_script       = "base_code64"
  }
}

```

### Configuration Details

**templates name**  The name of the template is designated based on the two regions, `AisaTech` and `Afranet`, using the syntax `$REGION-IMAGENAME`

**image_id** Specify the name of the image, which should be defined in the `opennebula_image` resource and populated in the `images.tfvars file`, and created in OpenNebula.

**network_ids** Specify the network names, which should be defined in the `opennebula_virtual_network` resource and populated in the `networks.tfvars` file, and created in OpenNebula. You can define `one` or `two` networks.

**sched_requirements** This is set to `0` by default but may change in the future if the two regions are separated.

**start_script** This is a script created in the `Custom VARS` section, which is passed to OpenNebula in `base64` encoding and is created as clean text when the template is built. Ensure the script is written according to the operating system and passed in base64 format.

The remaining settings have fixed values and are not variable. They are defined in the main.tf file in the `/modules/resources` path under the `opennebula_template` resource.

Important Default Values:

```hcl

  cpu         = 2
  vcpu        = 2
  memory      = 4 * 1024
  group       = "oneadmin"
  permissions = "660"
  hot_resize {
    cpu_hot_add_enabled    = "YES"  
    memory_hot_add_enabled = "YES"  
  }    
  memory_max = 50 * 1024
  vcpu_max = "24"
  memory_resize_mode = "Hotplug"    
  context = {
    NETWORK         = "YES"
    NETWORK_CONTEXT = "YES"
    VMNAME          = "$NAME"
    PASSWORD_BASE64 = "PASSWORD"
    USERNAME        = "ecs"
    TIMEZONE        = "example"
    ROLEID          = "roleid"
    SECRETID        = "secretsis"
    START_SCRIPT_base64    = each.value.start_script
  }
  graphics {
    type   = "VNC"
    listen = "0.0.0.0"
  }
  os {
    arch        = "x86_64"
    boot        = ""
  }
  disk {
    image_id = opennebula_image.image[each.value.image_id].id

    target   = "vda"
    driver   = "qcow2"
    cache    = "default"
    discard  = "ignore"
    io       = "threads"
  }
  dynamic "nic" {
    for_each = length(each.value.network_ids) > 0 ? each.value.network_ids : [null]
    content {
      model      = "virtio"
      network_id = nic.value != null ? opennebula_virtual_network.virtual_networks[nic.value].id : null
      
    }
  }
  cpumodel {
    model = "host-passthrough"
  }

```

# Terraform OpenNebula Configuration: `Virtual Machine Resource`

The configurations for the opennebula_virtual_machine resource are located in the vms.tfvars file.

### Resource Configuration

The `opennebula_virtual_machine` source code is used to create a virtual machine.

#### Variables

- **virtual machine**: This variable is a map where each key-value pair represents a host and its configuration details.

#### Example Configuration

In the `vms.tfvars` file, you define the values as follows:

```hcl
vms = {
  "example-01.private.ecs.infra" = {
    template  = "Afra-Ubuntu24.04"
    memory    = 3  # GB    
    cpu       = 2
    vcpu      = 5
    disk_size = 45   # GB, Be careful that the numerical value is not less than the current number
    additional_disk  = {
      size     = 20  # GB, Be careful that the numerical value is not less than the current number
      target   = "vdb"
      type     = "fs"
      format   = "qcow2"
    }
    networks = []
    sched_requirements = "Nebula-master-01.ecs.infra"
    labels     = "DevOps, LV.1"    
    group              = "oneadmin"
    permissions        = "640"
  },
  "example-02.private.app.ecs.infra" = {
    template  = "Afra-Ubuntu24.04"
    memory    = 5   # GB    
    cpu       = 2
    vcpu      = 4
    disk_size = 27   # GB
    additional_disk  = null
    networks = [
      { network = "ecs-10G", ip = "172.20.2.203" }
    ]
    sched_requirements = "Nebula-worker-02.ecs.infra"
    labels     = "DBA, Critical-DB"
    group              = "oneadmin"
    permissions        = "640"    
  }
}

```

### Configuration Details

**template** Specify the name of the template, which should be defined in the `opennebula_template resource`, populated in the `templates.tfvars` file, and created in OpenNebula.

**start_script** This configuration is based on the removal of CI keys allocated for database machines. As shown below, the commands related to Vault for retrieving the CI public key have been removed.

If this parameter is set to null, the value from the template will be used. If it is assigned a value, it will replace the existing value in the template.
```hcl
start_script = ""
```
The value of script_base_64 to be used for database machines is provided below.
```hcl
base_code64
```

**memory** The amount of RAM required for the virtual machine, specified in gigabytes.

**CPU** The number of CPUs required for the virtual machine.

**vcpu** The number of vCPUs required, which should align with the number of CPUs.

## For resizing in hotplug mode, both RAM and VCPU need to be adjusted

- Regarding the `VCPU` change, there is no issue; you can increase or decrease the number as needed.

- As for `RAM` changes, you start with an initial amount. You can increase this amount, but you cannot decrease it. To decrease RAM, you can only revert to the initial amount, which will be accepted. This limitation is due to the DIMM.

- `I should also mention that the RAM change rule applies not just when setting up a virtual machine with Terraform, but also when you manually create a virtual machine using hotplug. You will encounter the same DIMM error, so it's important to follow the standard procedure.`

**disk_size** The size of the `main disk` for the virtual machine, specified in gigabytes, according to the requirements for creating the machine.

**additional_disk** This specifies a second disk if a partition other than the main partition is requested for the virtual machine. If no additional partition is requested, set this to `null`.

- If no additional partition is requested

```hcl
  additional_disk = null
```

- If an additional partition is requested

```hcl
additional_disk = {
  size     = 20  # GB, Be careful that the numerical value is not less than the current number
  target   = "vdb"
  type     = "fs"
  format   = "qcow2"
}
```

For Linux base and Windows machines, consider the following:

- **Linux base**

```hcl
additional_disk = {
  size     = 20  # GB, Be careful that the numerical value is not less than the current number
  target   = "vdb"
  type     = "fs"
  format   = "qcow2"
}
```

- **Windows**

```hcl
additional_disk = {
  size     = 20  # GB, Be careful that the numerical value is not less than the current number
  target   = "hda"
  type     = "fs"
  format   = "raw"
}
```

**networks** Specify the IP address for each network. You can add multiple networks if needed.

- **leave the IP address empty**

```hcl
networks = [
  { network = "ecs-10G", ip = "" },
  { network = "ecs-DB", ip = "" }
]

```

- **specify a desired IP address**

```hcl
networks = [
  { network = "ecs-10G", ip = "172.40.2.203" }
]
```  

**sched_requirements** The host where the virtual machine will be provisioned, e.g., `one-01.compute.afra.snapp.infra`

**labels** ags used to identify the machine, including:

1. The requesting team's name.

2. Service sensitivity, which has three levels

- **LV.1** No changes during the day as it will definitely cause a business incident.
- **LV.2** Potential for business disruption; changes should be tested and approved before implementation.
- **LV.3** No business impact; changes can be made during the day.

### These three values are specified by the requester in the virtual machine request

3. Additionally, there are two other tags for highly sensitive database virtual machines

- **DB-Master**  The database virtual machine currently holding the master role.
- **DB-Critical** The number of virtual machines with the slave role for the DB-Master.

Coordinate with the DBA team for updates on these tags.  

4. For example, regarding the tags, it could be structured as follows:
- **LABELS = "DBA, LV.1, DB-Critical"**
- **LABELS = "Dispatching, LV.3, Temporary"**


**Please Note:**

Regarding the labels tag in Nebula, here are a few points to consider:

Specify the team name, either in its abbreviation or full form.
For example:
Abbreviation: `Teams like DBA or DER`
Full form: `Teams like Smapp`
Write full names with the first letter `capitalized` (e.g., Smapp), and abbreviations in full `uppercase` (e.g., DER or DBA).

If you're adding a new name, search for it in the vms.tfvars configuration file to check if it `already exists`. Use the same format to avoid creating two different names for the same tag in Nebula.

For temporary, test, or staging machines, do not set the Service Level (LV). Instead, only assign the team name and the Temporary tag.

**group** All virtual machines have the `oneadmin` group, except for specific machines which may have their own group for special access, e.g., `powerbi-01.app.afra.snapp.infra`, which belongs to the `onedatateam` group.

**permissions** Access levels are Use, Manage, and Admin for Owner, Group, and Other. For the `oneadmin` group, the permissions value is `0640`.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing

Please read [CONTRIBUTING](CONTRIBUTING.md) for details on our code of conduct, and the process for submitting pull requests to us.

---

For any questions or issues, feel free to open an issue in this repository.
