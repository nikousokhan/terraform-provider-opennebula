import hcl
import subprocess

def load_vars(file_path):
    with open(file_path, 'r') as f:
        return hcl.load(f)

def get_previous_version(file_path):
    result = subprocess.run(["git", "show", f"HEAD~1:{file_path}"], stdout=subprocess.PIPE, text=True)
    return hcl.loads(result.stdout)

def check_increasing_values(old_vars, new_vars):
    errors = []
    for vm_name, vm_details in new_vars['vms'].items():
        old_vm_details = old_vars['vms'].get(vm_name)
        if old_vm_details:
            if vm_details['disk_size'] < old_vm_details['disk_size']:
                errors.append(f"Error: disk_size for {vm_name} decreased from {old_vm_details['disk_size']} to {vm_details['disk_size']}")
            if 'additional_disk' in vm_details and 'additional_disk' in old_vm_details:
                if vm_details['additional_disk'] is not None and isinstance(vm_details['additional_disk'], dict) and \
                   old_vm_details['additional_disk'] is not None and isinstance(old_vm_details['additional_disk'], dict):
                    if vm_details['additional_disk']['size'] < old_vm_details['additional_disk']['size']:
                        errors.append(f"Error: additional_disk.size for {vm_name} decreased from {old_vm_details['additional_disk']['size']} to {vm_details['additional_disk']['size']}")
    return errors

# Load current and previous versions of vms.tfvars
new_vars = load_vars('vms.tfvars')
old_vars = get_previous_version('vms.tfvars')

if new_vars is None or old_vars is None:
    print("Error: Failed to load variables.")
    exit(1)

# Check if values are increasing for existing VMs
errors = check_increasing_values(old_vars, new_vars)
if errors:
    for error in errors:
        print(f"\033[91m{error}\033[0m")  # Print errors in red
    exit(1)
