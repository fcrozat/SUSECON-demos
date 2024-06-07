# SLE Micro demos for SUSECON 2024

## Best OS to run containers
### Why ?
SLE Micro 6.x can run workloads in both containers and VM. 

Let's see why we think it is the best OS to run your container workloads.

### Requirements
* SLE Micro 6.0 Default image: download from <https://www.suse.com/download/sle-micro/> image named **SLE-Micro.x86_64-6.0-Default-qcow-GM.qcow2**

### Setup
* Checkout <https://github.com/fcrozat/SUSECON-demos/tree/main/VM/deploy-container> directory
* Copy VM image to /**var/lib/libvirt/images/susecon-slmicro6-talk.qcow2**
* Edit libvirt xml definition with the real path for ignition file **config-SUSECON.ign** and combustion script **script-SUSECON**
* Edit `config-SUSECON.ign`  with password hash for root user. You can generate it using:
`openssl passwd -6 -salt $(head -c18 /dev/urandom | openssl base64)`
* Edit `script-SUSECON` with your SCC credentials.

### Run demo
#### Initial deployment
* Boot VM
* Initial setup is done using [Ignition](https://coreos.github.io/ignition/) and [Combustion](https://github.com/openSUSE/combustion). You can create your own files using [Fuel Ignition](https://opensuse.github.io/fuel-ignition/).
* Once booted, login as root to cockpit running on the VM (address visible on login prompt)
* Two containers are already deployed and running
    + [mariadb](https://registry.suse.com/repositories/suse-mariadb) container, using SLE BCI container 
    + wordpress container, build on OBS <https://build.opensuse.org/package/show/home:fcrozat:SUSECON/wordpress-demo>, based on SLE BCI [PHP8 container](https://registry.suse.com/repositories/bci-php-apache)
* Container configuration is done using quadlets, stored in `/etc/containers/systemd`
* Container status can be checked using `podman ps` or in cockpit podman section
* Wordpress can be setup on _http://<VM_ip>/_

#### Host reliability
* let's try to break OS by simulating broken changes to the host
* two additional health-checks were deployed on the image :
    + sshd service check
    + podman being present on the system
    + those health-checkers scripts were deployed to `/usr/libexec/health-checker/`
* Let's uninstall ssh server
    + `transactional-update pkg rm openssh-server`
    + openssh-server and its dependencies are removed in a snapshot which is becoming only live after reboot
    + reboot (in fact, the system will reboot twice)
    + check if sshd is still running: health-checker caused an automated rollback due to sshd not running in the new snapshot
    + check `openssh-server` is still installed
* Let's try to remove podman
    + `transactional-update pkg rm podman`
    + reboot (it will reboot twice)
    + podman is still there, container are still running

#### Container update and rollback
* Container image update can be fully automated using podman-auto-update which will monitor if new image are available (on registry or locally) and will restart the container accordingly
* Behavior is controlled by container, in quadlet definition `AutoUpdate=registry` (or `local`)
* Maintenance window can be configured with `podman-auto-update.timer`

##### Deploying broken container
* let's build wordpress container locally using: `/root/container/build.sh`
* run `podman auto-update --dry-run`: one container is pending update
* run `podman auto-update` : wordpress container is restarted, wordpress can still be accessed
* let's break the container. Edit `/root/container/build.sh` and uncomment the chmod -x line
* build using `/root/container/build.sh`
* deploy the update using `podman auto-update`
* new container wouldn't start properly, podman rolled-back to the previous image, which is restarted and running. Wordpress is still accessible

## Full disk encryption demo
### Why ?
SLE Micro 6.0 introduced Full-Disk Encryption integrated with TPM 2.0, allowing unattended system boot, protecting from offline attacks.

### Requirements
* SLE Micro 6.0 Encrypted image: download from <https://www.suse.com/download/sle-micro/> image named **SLE-Micro.x86_64-6.0-Default-encrypted-GM.raw**
* x86_64 UEFI Secure boot system with TPM 2.0 chip

### Setup
* grab libvirt VM XML definitions from <https://github.com/fcrozat/SUSECON-demos/tree/main/VM/fde>
* copy **SLE-Micro.x86_64-6.0-Default-encrypted-GM.raw** to your libvirt image directory (usually `/var/lib/libvirt/images`) as name **susecon-slmicro6-fde.raw**
* Import two VM definitions using  `virsh define --file your_vm_definition.xml`
* You will have 2 VMS, one with (virtual) TPM 2.0 chip and another without. Both are sharing the same disk image.

### Running demo
#### Initial deployment
* Start susecon-slem6-fde VM
* Initial boot (until Grub2 is displayed) is very slow, due to initial decryption being done in Real x86 mode by grub2
* Choose the default in grub2 and follow the boot sequence
* Ensure Full disk enrollment is done, with TPM and also setup a recovery passphrase.
* Login, check system is encrypted (`lsblk`)
* Reboot. No passphrase prompt and double-check system is still encrypted
* Shutdown VM

#### Simulate unauthorized offline access
* Now, let's simulate a unauthorized access to the encrypted disk (somebody stole it or it is move to another physical system)
* Boot non TPM VM
* System will not boot. Instead grub2 asks for passphrase. You can enter recovery passphrase to continue booting
* Shutdown VM
* Boot initial TPM VM : system will boot without human intervention since the keys in TPM chip are still valid.
