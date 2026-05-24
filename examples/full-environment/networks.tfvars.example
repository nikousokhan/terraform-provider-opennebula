  networks = {
#=============================================================Vlan170_Afranet(10G)
    Afra-10G = {
      name            = "vlan170"
      bridge          = "br0"
      type            = "bridge"
      gateway         = "172.20.3.254"
      network_mask    = "255.255.252.0"
      network_address = null
      mtu             = null
      ar              = [
        { ar_type = "IP4", size = 180, ip4 = "172.20.0.50" },
        { ar_type = "IP4", size = 254, ip4 = "172.20.1.1" },
        { ar_type = "IP4", size = 254, ip4 = "172.20.2.1" },
        { ar_type = "IP4", size = 254, ip4 = "172.20.3.1" }        
      ]
      VN_MAD = "bridge"
    },
#=============================================================Vlan240_Afranet(DBA)
    Afra-DB = {
      name            = "vlan240"
      bridge          = "br-db"
      type            = "bridge"
      gateway         = null
      network_mask    = "255.255.254.0"
      network_address = "172.16.24.0"
      mtu             = "9000"
      ar              = [
        { ar_type = "IP4", size = 440, ip4 = "172.16.24.60" }
      ]
      VN_MAD = "bridge"
    },
#=============================================================Vlan255_Afranet(LB_DevOps)
    Afra-LB = {
      name            = "vlan255"
      bridge          = "br-lb"
      type            = "bridge"
      gateway         = null
      network_mask    = "255.255.245.0"
      network_address = "172.20.255.0"
      mtu             = "9000"
      ar              = [
        { ar_type = "IP4", size = 255, ip4 = "172.20.255.1" }
      ]
      VN_MAD = "bridge"
    },
#=============================================================Vlan184_Afranet(VRF)
    Afra-VRF-184 = {
      name            = "vlan184"
      bridge          = "br-vrf-184"
      type            = "bridge"
      gateway         = null
      network_mask    = "255.255.255.192"
      network_address = "172.165.18.128"
      mtu             = null
      ar              = [
        { ar_type = "IP4", size = 61, ip4 = "172.16.18.130" }
      ]
      VN_MAD = "bridge"
    },
#=============================================================Vlan185_Afranet(VRF)
    Afra-VRF-185 = {
      name            = "vlan185"
      bridge          = "br-vrf-185"
      type            = "bridge"
      gateway         = null
      network_mask    = "255.255.255.192"
      network_address = "172.165.18.192"
      mtu             = null
      ar              = [
        { ar_type = "IP4", size = 61, ip4 = "172.16.18.194" }
      ]
      VN_MAD = "bridge"
    },
#=============================================================Vlan192_Afranet(VRF)
    Afra-VRF-192 = {
      name            = "vlan192"
      bridge          = "br-vrf-192"
      type            = "bridge"
      gateway         = null
      network_mask    = "255.255.255.192"
      network_address = "172.165.19.64"
      mtu             = null
      ar              = [
        { ar_type = "IP4", size = 60, ip4 = "172.16.19.66" }
      ]
      VN_MAD = "bridge"
    },
#=============================================================Vlan32_Afranet(Backup-DC)
    Afra-BK = {
      name            = "vlan32"
      bridge          = "br-bk"
      type            = "bridge"
      gateway         = null
      network_mask    = "255.255.255.0"
      network_address = "172.18.88.0"
      mtu             = null
      ar              = [
        { ar_type = "IP4", size = 252, ip4 = "172.18.88.1" }
      ]
      VN_MAD = "bridge"
    },    
#=============================================================Vlan209_Asia(10G)
    Asia-10G = {
      name            = "vlan209"
      bridge          = "br-10g-lan"
      type            = "bridge"
      gateway         = "172.21.6.254"
      network_mask    = "255.255.255.0"
      network_address = "172.21.6.0"
      mtu             = null
      ar              = [
        { ar_type = "IP4", size = 252, ip4 = "172.21.6.10" }
      ]
      VN_MAD = "bridge"
    },
#=============================================================Vlan203_Asia(DBA)
    Asia-DB = {
      name            = "vlan203"
      bridge          = "br-db-203"
      type            = "bridge"
      gateway         = null
      network_mask    = "255.255.255.0"
      network_address = "172.21.3.0"
      mtu             = "9000"
      ar              = [
        { ar_type = "IP4", size = 252, ip4 = "172.21.3.2" }
      ]
      VN_MAD = "bridge"
    },
#=============================================================Vlan184_Asia(VRF)
    Asia-VRF-184 = {
      name            = "Asia-vlan184"
      bridge          = "br-vrf-184"
      type            = "bridge"
      gateway         = null
      network_mask    = "255.255.255.224"
      network_address = "172.21.18.96"
      mtu             = null
      ar              = [
        { ar_type = "IP4", size = 29, ip4 = "172.21.18.98" }
      ]
      VN_MAD = "bridge"
    },
#=============================================================Vlan185_Asia(VRF)
    Asia-VRF-185 = {
      name            = "Asia-vlan185"
      bridge          = "br-vrf-185"
      type            = "bridge"
      gateway         = null
      network_mask    = "255.255.255.224"
      network_address = "172.21.18.128"
      mtu             = null
      ar              = [
        { ar_type = "IP4", size = 29, ip4 = "172.21.18.130" }
      ]
      VN_MAD = "bridge"
    }
  }
