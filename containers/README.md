 ## This directories contains all the files to demo how to use systemd integration with podman (formely know as quadlets) 

 Goal: create a wordpress blog with two containers, one running mariadb, another running wordpress with Apache+PHP 

* mariadb container
  + `mariadb.container`: podmand systemd definition file
  + `notify-systemd.sh`: script used to notify host systemd mariadb engine is ready to process requests

* wordpress container
  + `Dockerfile`: container definition for wordpress  on top of SUSE SLE BCI Apache+PHP container
  + `build.sh`: script to build and tag wordpress container locally
  + `wp-config.php`: default configuration for wordpress

After installing each .container file in `/etc/containers/systemd`, you must run `systemctl daemon-reload`.

### Running everything together

* option 1: running each container separately
  + use `systemctl start mariadb` and `systemctl start wordpress`

* option 2: grouping both containers in pod to restrict network access
  + if using podman < 5.0, you should uncomment `PodmanArgs=--pod susecon` line in `.container` files
  + if using podman >= 5.0, you should uncomment `Pod=susecon` in `.container` files, copy susecon.pod and susecon.network to `/etc/containers/systemd`.
  + Then run `systemctl daemon-reload` and `systemctl start mariadb wordpress`.

* option 3: using K8s syntax
  + if you are more familiar with Kubernetes or want to transition this setup to K8S, you can use `susecon.yaml` YAML configuration file and have podman manage it by copying `susecon.kube` and `susecon.yaml` to `/etc/containers/systemd`. Then run `systemctl daemon-reload` and `systemctl start susecon`.


