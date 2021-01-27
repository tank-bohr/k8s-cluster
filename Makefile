.PHONY: provision show-pods setup-dashboard dashboard-token dashboard http-echo-ips

OSNAME := $(shell uname -s)

ifeq ($(OSNAME), Darwin)
	OPEN    := open
	PBCOPY  := pbcopy
	PBPASTE := pbpaste
endif
ifeq ($(OSNAME), Linux)
	OPEN    := xdg-open
	PBCOPY  := xclip -selection clipboard
	PBPASTE := xclip -selection clipboard -o
endif

export KUBECONFIG=$(PWD)/admin.conf

provision: kube-flannel.yml
	ansible-playbook playbook.yml

kube-flannel.yml:
	curl https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml --remote-name

setup-dashboard: admin.conf
	kubectl apply --filename=https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0/aio/deploy/recommended.yaml

setup-dashboard-user: admin.conf
	kubectl apply --filename=dashboard-adminuser.yaml

dashboard-token:
	kubectl \
		--namespace=kubernetes-dashboard \
		--output=json \
		get secret \
		| jq --raw-output '.items | .[] | select(.metadata.annotations."kubernetes.io/service-account.name"=="admin-user") | .data.token' \
		| base64 --decode \
		| $(PBCOPY)

dashboard: dashboard-token
	$(OPEN) http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/
	kubectl proxy

http-echo-ips:
	kubectl get pods --selector=app=http-echo -o jsonpath='{.items[*].status.podIP}'
