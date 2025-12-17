vms = {
  "pgproxysql-cluster-a-01.app.afra.nikou.infra" = {
    template  = "Afra-Ubuntu24.04"
    memory    = 6
    cpu       = 2
    vcpu      = 2
    disk_size = 50
    additional_disk  = null
    networks = [
      { network = "Afra-10G", ip = "172.20.3.50" }
    ]
    sched_requirements = "one-13.compute.afra.nikou.infra"
    labels     = "DBA,LV.2"
    group              = "oneadmin"
    permissions        = "640"    
  },
    "pgproxysql-cluster-a-02.app.afra.nikou.infra" = {
    template  = "Afra-Ubuntu24.04"
    memory    = 6
    cpu       = 2
    vcpu      = 2
    disk_size = 50
    additional_disk  = null
    networks = [
      { network = "Afra-10G", ip = "172.20.3.51" }
    ]
    sched_requirements = "one-30.compute.afra.nikou.infra"
    labels     = "DBA,LV.2"
    group              = "oneadmin"
    permissions        = "640"    
  },          
}
