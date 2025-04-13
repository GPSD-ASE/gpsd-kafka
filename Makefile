NAMESPACE = gpsd
DEPLOYMENT = $(NAMESPACE)-kafka
SERVICE_NAME = $(DEPLOYMENT)
CHART_DIRECTORY = helm
REMOTE_CHART_REPOSITORY = gpsd-ase.github.io
VERSION := $(shell grep "version:" helm/Chart.yaml | head -1 | sed 's/version: //')

# Kubernetes commands
.PHONY: helm helm-uninstall helm-clean
develop: helm

helm:
	@echo "Upgrading/Installing $(DEPLOYMENT) Helm chart..."
	helm upgrade --install demo ./helm --namespace $(NAMESPACE)

helm-uninstall:
	@echo "Uninstalling $(DEPLOYMENT) from Kubernetes..."
	helm uninstall demo -n $(NAMESPACE) || true

helm-clean:
	@echo "Cleaning up Kafka resources in the $(NAMESPACE) namespace..."
	kubectl delete deployment demo-kafka-broker -n $(NAMESPACE) || true
	kubectl delete deployment demo-kafka-ui -n $(NAMESPACE) || true
	kubectl delete service demo-kafka-broker -n $(NAMESPACE) || true
	kubectl delete service demo-kafka-ui -n $(NAMESPACE) || true
	kubectl delete pvc demo-kafka-broker-pvc -n $(NAMESPACE) || true
	kubectl delete sa demo-sa -n $(NAMESPACE) || true

# Release and versioning
.PHONY: release bump-version update-changelog
release: update-changelog bump-version

update-changelog:
	@echo "Updating changelog..."
	./scripts/update-changelog.sh

bump-version:
	@echo "Bumping version..."
	./scripts/bump-version.sh

# GitHub Pages and Helm chart publishing
.PHONY: gh-pages-publish helm-repo-update

gh-pages-publish:
	@echo "Publishing Helm chart for $(SERVICE_NAME) to GitHub Pages..."
	rm -rf /tmp/$(NAMESPACE)/*
	mkdir -p /tmp/$(NAMESPACE)/
	helm package ./$(CHART_DIRECTORY) -d /tmp/$(NAMESPACE)/
	helm repo index /tmp/$(NAMESPACE)/ --url https://$(REMOTE_CHART_REPOSITORY)/$(SERVICE_NAME)/ --merge /tmp/$(NAMESPACE)/index.yaml
	git checkout gh-pages || git checkout -b gh-pages
	cp /tmp/$(NAMESPACE)/* .
	ls .
	git status
	git add .
	git commit -m "chore: update Helm chart to v$(VERSION)"
	git push origin gh-pages
	git checkout main

helm-repo-update:
	@echo "Adding and updating Helm repo for $(SERVICE_NAME)..."
	helm repo add $(SERVICE_NAME) https://$(REMOTE_CHART_REPOSITORY)/$(SERVICE_NAME)/
	helm repo update
	helm repo list

refresh:
	git fetch -v && git pull origin main --rebase