export KUBECONFIG = $(PWD)/admin.conf

provision: kube-flannel.yml
	ansible-playbook playbook.yml

kube-flannel.yml:
	curl https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml -O

show-pods: admin.conf
	kubectl get pods --all-namespaces
